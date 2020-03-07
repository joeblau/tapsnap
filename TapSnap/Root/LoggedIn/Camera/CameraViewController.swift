// CameraViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import AVFoundation
import CloudKit
import Combine
import CoreLocation
import MediaPlayer
import UIKit
import os.log

final class CameraViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()
    
    var tapNotificationCount = 0 {
        didSet {
            DispatchQueue.main.async {
                self.notificationButton.setTitle("\(self.tapNotificationCount)", for: .normal)
                switch self.tapNotificationCount {
                case 0:
                    self.notificationButton.isHidden = true
                default:
                    self.notificationButton.isHidden = false
                }
            }
        }
    }
    var sendCancellable: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.cancelSendButton.isHidden = !self.sendCancellable
                self.cancelBackground.isHidden = !self.sendCancellable
            }
        }
    }
    var currentGroup: CKRecord? = nil
    
    
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
        let r = UIPanGestureRecognizer(target: self, action: #selector(zoomCameraAction(_:)))
        r.delegate = self
        return r
    }()
    
    // Top center
    
    private lazy var cancelSendButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(scale: .small)), for: .normal)
        b.addTarget(self, action: #selector(cancelSendAction), for: .touchUpInside)
        b.setTitle(" Cancel Send", for: .normal)
        b.tintColor = .label
        b.backgroundColor = .systemBlue
        b.layer.cornerRadius = 8
        b.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        b.isHidden = true
        return b
    }()
    
    private lazy var cancelBackground: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
        v.isHidden = true
        return v
    }()
    
    // Top right
    lazy var notificationButton: UIButton = {
        let b = UIButton(type: .custom)
        b.notification(diameter: 20)
        b.addTarget(self, action: #selector(showPlaybackAction), for: .touchUpInside)
        b.isHidden = true
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
        navigationItem.titleView = cancelSendButton
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
        
        sessionQueue.async {
            self.session.bootstrap()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sessionQueue.async {
            self.session.startRunning()
            
            self.session.initZoom()
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
    
    @objc private func cancelSendAction() {
        Current.mediaActionSubject.send(.cancelMediaStart)
    }
    
    func cleanUp(url: URL) {
        switch backgroundRecordingID {
        case let .some(backgroundID) where backgroundID != .invalid:
            backgroundRecordingID = .invalid
            UIApplication.shared.endBackgroundTask(backgroundID)
        case .some(_):
            backgroundRecordingID = .invalid
        case .none: break
        }
        
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            try FileManager.default.removeItem(atPath: url.path)
        } catch {
            os_log("%@", log: .fileManager, type: .error, error.localizedDescription)
        }
    }
    
    private func startCancelCountdown() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            Current.mediaActionSubject.send(.cancelMediaEnd)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension CameraViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        true
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
        
        view.addSubview(cancelBackground)
        cancelBackground.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        cancelBackground.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
        cancelBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        cancelBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        cancelSendButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        cancelSendButton.widthAnchor.constraint(equalToConstant: 180).isActive = true
    }
    
    internal func configureStreams() {
        Current.activeCameraSubject.sink { position in
            self.sessionQueue.async {
                self.session.setCamera(to: position)
            }
        }.store(in: &cancellables)
        
        Current.presentViewContollersSubject
            .removeDuplicates()
            .sink { present in
            switch present {
            case .camera:
                self.dismiss(animated: true) {
                    self.playbackViewController.viewControllers.removeAll()
                    CKContainer.default().loadInbox()
                    self.session.enableBackgroundAudio()
                }
            case .playback:
                Current.inboxURLsSubject.value?.forEach { url in
                    self.playbackViewController.pushViewController(PlaybackViewController(messageURL: url), animated: false)
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
            case .none:
                self.sendCancellable = false
            case .capturePhoto:
                self.sendCancellable = true
                self.photoSettings.isHighResolutionPhotoEnabled = false
                self.photoSettings.photoQualityPrioritization = .speed
                if !self.photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
                    self.photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: self.photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
                }
                
                AVCaptureSession.photoOutput.capturePhoto(with: self.photoSettings, delegate: self)
                self.previewView.flash()
                self.startCancelCountdown()
            case .captureVideoStart:
                self.sendCancellable = false
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

                let videoMetadata =  [AVMetadataItem].movieMetadata(group: self.currentGroup?[GroupKey.name] as? String)
                AVCaptureSession.movieFileOutput.metadata?.append(contentsOf: videoMetadata)
                AVCaptureSession.movieFileOutput.startRecording(to: URL.randomOutboxSaveURL(with: .mov), recordingDelegate: self)
            case .captureVideoEnd:
                self.sendCancellable = true
                if Current.musicSyncSubject.value {
                    MPMusicPlayerController.systemMusicPlayer.stop()
                }
                AVCaptureSession.movieFileOutput.stopRecording()
                self.previewView.flash()
                self.startCancelCountdown()
            case .cancelMediaStart:
                Current.outboxRecordsSubject.send(nil)
                self.sendCancellable = false
            case .cancelMediaEnd:
                self.sendCancellable = false
                CKContainer.default().sendMessages()
            }
        }.store(in: &cancellables)
        
        Current.zoomVeloictySubject.sink { zoomVelocity in
            self.session.zoom(with: Float(zoomVelocity.y))
        }.store(in: &cancellables)
        
        Current.cloudKitGroupsSubject.sink { groups in
            guard let groups = groups else { return }
            DispatchQueue.main.async {
                let items = groups.compactMap({ record -> GroupValue? in
                    guard let name = record["name"] as? String else { return nil }
                    return GroupValue(name: name, record: record)
                })
                
                var snapshot = NSDiffableDataSourceSnapshot<GroupSection, GroupValue>()
                snapshot.appendSections([.groups])
                snapshot.appendItems(items, toSection: .groups)
                self.contactsCollectionView.diffableDataSource?.apply(snapshot)
                self.contactPageControl.numberOfPages = Int(ceil(Double(items.count) / 8.0))
            }
        }.store(in: &cancellables)
        
        Current.cloudKitSelectedGroupSubject.sink { currentGroup in
            self.currentGroup = currentGroup
        }.store(in: &cancellables)
        
        Current.inboxURLsSubject.sink { urls in
            switch urls {
            case let .some(urls): self.tapNotificationCount = urls.count
            case .none: break
            }
        }.store(in: &cancellables)
        
        Current.cleanupSubject.sink { cleanup in
            switch cleanup {
            case let .cleanUp(url): self.cleanUp(url: url)
            default: break
            }
        }.store(in: &cancellables)
    }
    
    func configureGestureRecoginzers() {
        previewView.addGestureRecognizer(zoomInOutPan)
    }
}
