// CameraViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import AVFoundation
import CloudKit
import Combine
import CoreLocation
import MediaPlayer
import UIKit

final class CameraViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()

    let tapNotificationCount = 0
    let itemsInSection = [0]

    // Photo Video
    private let session: AVCaptureSession = { AVCaptureSession() }()
    let sessionQueue = DispatchQueue(label: "session queue")
    var backgroundRecordingID: UIBackgroundTaskIdentifier?
    var photoData: Data?
    var photoSettings: AVCapturePhotoSettings {
        switch AVCaptureSession.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
        case true: return AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        case false: return AVCapturePhotoSettings()
        }
    }

    // Top left
    private lazy var menuButton: UIBarButtonItem = {
        let b = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"),
                                style: .plain,
                                target: self,
                                action: #selector(showMenuAction))
        b.tintColor = .label
        return b
    }()

    private lazy var clearButton: UIBarButtonItem = {
        let b = UIBarButtonItem(image: UIImage(systemName: "clear"),
                                style: .plain,
                                target: self,
                                action: #selector(clearEditingAction))
        b.tintColor = .label
        return b
    }()

    private lazy var zoomInOutPan: UIPanGestureRecognizer = {
        UIPanGestureRecognizer(target: self, action: #selector(zoomCameraAction(_:)))
    }()

    // Top right
    lazy var notificationButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("\(tapNotificationCount)", for: .normal)
        b.notification(diameter: 20)
        b.isHidden = tapNotificationCount == 0
        return b
    }()

    private lazy var previewView: CameraPreviewView = {
        CameraPreviewView(session: session)
    }()

    let contactPageControl = UIPageControl()

    private lazy var contactsCollectionView: ContactsCollectionView = {
        let cv = ContactsCollectionView()
        cv.delegate = self
        return cv
    }()

    private lazy var menuViewController: UINavigationController = {
        UINavigationController(rootViewController: MenuViewController())
    }()

    private lazy var searchViewController: UINavigationController = {
        UINavigationController(rootViewController: SearchContactsViewController())
    }()

    private lazy var playbackViewController: UINavigationController = {
        let nc = UINavigationController()
        nc.modalPresentationStyle = .overCurrentContext
        nc.isToolbarHidden = false
        return nc
    }()

    // MARK: - Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
        bootstrap()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = menuButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: notificationButton)

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { _ in
                self.sessionQueue.resume()
            })
        default: break
        }

        toolbarItems = [
            UIBarButtonItem(title: "Edit", style: .plain, target: self, action: nil),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(customView: contactPageControl),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchContactsAction)),
        ]

        contactPageControl.numberOfPages = Int(ceil(Double(itemsInSection[0]) / 8.0))
        sessionQueue.async {
            self.session.bootstrap()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sessionQueue.async {
            self.session.startRunning()
        }
    }

    // MARK: - Actions

    @objc private func showPlaybackAction() {
        Current.presentViewContollersSubject.value = .playback
    }

    @objc private func showMenuAction() {
        Current.presentViewContollersSubject.value = .menu
        present(menuViewController, animated: true, completion: nil)
    }

    @objc private func clearEditingAction() {
        Current.editingSubject.value = .clear
    }

    @objc private func editContacts() {}

    @objc private func searchContactsAction() {
        present(searchViewController, animated: true, completion: nil)
    }

    @objc private func zoomCameraAction(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            let velocity = recognizer.velocity(in: previewView)
            Current.zoomVeloictySubject.send(velocity)
        default: break
        }
    }
}

// MARK: - ViewBootstrappable

extension CameraViewController: ViewBootstrappable {
    func configureViews() {
        view.addSubview(contactsCollectionView)
        contactsCollectionView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2.0).isActive = true
        contactsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        contactsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contactsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        view.addSubview(previewView)
        previewView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: contactsCollectionView.topAnchor).isActive = true
        previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    internal func configureStreams() {
        Current.activeCameraSubject.sink { position in
            self.sessionQueue.async {
                self.session.setCamera(to: position)
            }
        }.store(in: &cancellables)

        Current.presentViewContollersSubject.sink { present in
            switch present {
            case .camera:
                self.dismiss(animated: true) {
                    self.session.enableBackgroundAudio()
                }
            case .playback:
                (0 ..< self.tapNotificationCount).forEach { _ in
                    self.playbackViewController.pushViewController(PlaybackViewController(), animated: false)
                }
                self.present(self.playbackViewController, animated: true) {
                    self.session.disableBackgroundAudio()
                }
            case .none, .menu, .search: break
            }
        }.store(in: &cancellables)

        Current.topLeftNavBarSubject.sink { leftNavBarItem in
            switch leftNavBarItem {
            case .none:
                self.navigationItem.leftBarButtonItem = nil
            case .menu:
                self.navigationItem.leftBarButtonItem = self.menuButton
            case .clear:
                self.navigationItem.leftBarButtonItem = self.clearButton
            }
        }.store(in: &cancellables)

        Current.editingSubject.sink { editState in
            switch editState {
            case .none:
                self.zoomInOutPan.isEnabled = true
            default:
                self.zoomInOutPan.isEnabled = false
            }
        }.store(in: &cancellables)

        Current.mediaActionSubject.sink { action in
            switch action {
            case .none: break
            case .capturePhoto:
                if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                    Current.locationManager.requestLocation()
                }
                self.previewView.flash()

                self.photoSettings.isHighResolutionPhotoEnabled = false
                self.photoSettings.photoQualityPrioritization = .speed
                if !self.photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
                    self.photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: self.photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
                }

                AVCaptureSession.photoOutput.capturePhoto(with: self.photoSettings, delegate: self)
            case .captureVideoStart:
                if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                    Current.locationManager.requestLocation()
                }
                if Current.musicSyncSubject.value {
                    MPMusicPlayerController.systemMusicPlayer.prepareToPlay { _ in
                        MPMusicPlayerController.systemMusicPlayer.play()
                    }
                }
                if UIDevice.current.isMultitaskingSupported {
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }

                let movieFileOutputConnection = AVCaptureSession.movieFileOutput.connection(with: .video)
                movieFileOutputConnection?.videoOrientation = .portrait

                if AVCaptureSession.movieFileOutput.availableVideoCodecTypes.contains(.hevc) {
                    AVCaptureSession.movieFileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: movieFileOutputConnection!)
                }

                let outputFileName = NSUUID().uuidString
                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)

                AVCaptureSession.movieFileOutput.metadata = [AVMetadataItem].movieMetadata()
                AVCaptureSession.movieFileOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
            case .captureVideoEnd:
                if Current.musicSyncSubject.value {
                    MPMusicPlayerController.systemMusicPlayer.stop()
                }
                self.previewView.flash()
                AVCaptureSession.movieFileOutput.stopRecording()
            }
        }.store(in: &cancellables)

        Current.zoomVeloictySubject.sink { zoomVelocity in
            self.session.zoom(with: Float(zoomVelocity.y))
        }.store(in: &cancellables)

        Current.cloudKitGroupsSubject.sink { groups in

            guard let items = groups?.compactMap({ record -> GroupValue? in
                guard let name = record["name"] as? String else { return nil }
                return GroupValue(name: name)
            }) else {
                return
            }

            var snapshot = NSDiffableDataSourceSnapshot<GroupSection, GroupValue>()
            snapshot.appendSections([.contacts, .addContact])
            snapshot.appendItems(items, toSection: .contacts)
            snapshot.appendItems([GroupValue(name: "add")], toSection: .addContact)
            self.contactsCollectionView.diffableDataSource?.apply(snapshot)

        }.store(in: &cancellables)
    }

    internal func configureButtonTargets() {
        notificationButton.addTarget(self, action: #selector(showPlaybackAction), for: .touchUpInside)
    }

    func configureGestureRecoginzers() {
        previewView.addGestureRecognizer(zoomInOutPan)
    }
}
