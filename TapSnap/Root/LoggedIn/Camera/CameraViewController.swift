//
//  CameraViewController.swift
//  Dolo
//
//  Created by Joe Blau on 2/1/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit
import Combine
import AVFoundation

final class CameraViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()
    
    private let photoOutput = AVCapturePhotoOutput()
    let photoSettings: AVCapturePhotoSettings = {
        let ps = AVCapturePhotoSettings()
        ps.isHighResolutionPhotoEnabled = false
        ps.photoQualityPrioritization = .speed
        if !ps.__availablePreviewPhotoPixelFormatTypes.isEmpty {
            ps.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: ps.__availablePreviewPhotoPixelFormatTypes.first!]
        }
        return ps
    }()
    private var movieFileOutput = AVCaptureMovieFileOutput()
     var backgroundRecordingID: UIBackgroundTaskIdentifier?
    
    let movieCaputreQueue = DispatchQueue(label: "captured-movie")
    
    private let tapNotificationCount = 8
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
    
    // Top right
    lazy var notificationButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("\(tapNotificationCount)", for: .normal)
        b.notification(diameter: 20)
        return b
    }()
    
    let itemsInSection = [15]
    private lazy var previewView: CameraPreviewView = {
        return CameraPreviewView(session: session)
    }()
    private let session = AVCaptureSession()
    let sessionQueue = DispatchQueue(label: "session queue")
    
    let contactPageControl = UIPageControl()
    private lazy var contactsCollectionView: ContactsCollectionView = {
        let vc = ContactsCollectionView()
        vc.register(ContactCollectionViewCell.self,
                    forCellWithReuseIdentifier: ContactCollectionViewCell.id)
        vc.isPagingEnabled = true
        vc.dataSource = self
        vc.delegate = self
        vc.bounces = false
        return vc
    }()
    
    private lazy var menuViewController: UINavigationController = {
        let nc =  UINavigationController(rootViewController: MenuViewController())
        return nc
    }()
    
    private lazy var searchViewController: UINavigationController = {
        let nc = UINavigationController(rootViewController: SearchContactsViewController())
        return nc
    }()
    
    private lazy var playbackViewController: UINavigationController = {
        let nc = UINavigationController()
        nc.modalPresentationStyle = .overCurrentContext
        nc.isToolbarHidden = false
        return nc
    }()
    
    // MARK: - Photo Video
    
    var photoData: Data?
    
    // MARK: - Lifecycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
        bootstrap()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = menuButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: notificationButton)
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
            
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. Suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
//                if !granted {
//                    self.setupResult = .notAuthorized
//                }
                self.sessionQueue.resume()
            })
            
        default:
            break
//            // The user has previously denied access.
//            setupResult = .notAuthorized
        }
        
        do {
            let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: nil)
            editButton.tintColor = .label
            
            let pageControlButton = UIBarButtonItem(customView: contactPageControl)
            contactPageControl.numberOfPages = Int(ceil(Double(itemsInSection[0]) / 8.0))
            
            let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchContactsAction))
            searchButton.tintColor = .label
            
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            toolbarItems = [editButton, spacer, pageControlButton, spacer,  searchButton]
        }
        
        sessionQueue.async {
            self.configureSession()
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
    
    @objc func editContacts() {}
    
    @objc func searchContactsAction() {
        present(searchViewController, animated: true, completion: nil)
    }
    
    // MARK: - Private
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
                                                                               mediaType: .video, position: .unspecified)
    
    private func configureSession() {
        session.beginConfiguration()
        
        session.inputs.forEach { captureInnput in
            session.removeInput(captureInnput)
        }
        if let videoDevice = initailzeCamera() {
            addCaptureDeviceInput(videoDevice: videoDevice)
        }
        addAudioInput()
        addPhotoOutput()
        addMovieOutput()
        
        session.commitConfiguration()
    }
    
    private func configureSessionUpdate() {
        self.session.beginConfiguration()
        if let videoDevice = changeCamera() {
            addCaptureDeviceInput(videoDevice: videoDevice)
        }
        self.session.commitConfiguration()
    }
    
    private func addCaptureDeviceInput(videoDevice: AVCaptureDevice) {
        do {
            let videoCaptureInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoCaptureInput) {
                session.addInput(videoCaptureInput)
            }
        } catch {
            fatalError("Could not create video device input")
        }
    }
    
    
    private func addAudioInput() {
        do {
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
            }
        } catch {
            fatalError("Could not add audio input to session device input")
        }
    }
    
    
    private func addPhotoOutput() {
        if session.canAddOutput(photoOutput) {
            photoOutput.isHighResolutionCaptureEnabled = true
            session.addOutput(photoOutput)
        } else {
            fatalError("Could not add photo output to the session")
        }
    }
    
    private func addMovieOutput() {
        if session.canAddOutput(movieFileOutput) {
            if let connection = movieFileOutput.connection(with: .video),
                connection.isVideoStabilizationSupported  {
                connection.preferredVideoStabilizationMode = .auto
            }
            session.addOutput(movieFileOutput)
        } else {
            fatalError("Could not add movie output to the session")
        }
    }
    
    
    // MARK: - Helpers
    
    private func initailzeCamera() -> AVCaptureDevice? {
        var defaultVideoDevice: AVCaptureDevice?
        
        // Choose the back dual camera, if available, otherwise default to a wide angle camera.
        
        if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            defaultVideoDevice = dualCameraDevice
        } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            // If a rear dual camera is not available, default to the rear wide angle camera.
            defaultVideoDevice = backCameraDevice
        } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            // If the rear wide angle camera isn't available, default to the front wide angle camera.
            defaultVideoDevice = frontCameraDevice
        }
        
        return defaultVideoDevice
    }
    
    private func changeCamera() -> AVCaptureDevice? {
        guard let captureDeviceInput = self.session.inputs.first(where: { $0 is AVCaptureDeviceInput}) as? AVCaptureDeviceInput else {
            return nil
        }
        let currentVideoDevice = captureDeviceInput.device
        let currentPosition = currentVideoDevice.position
        
        let preferredPosition: AVCaptureDevice.Position
        let preferredDeviceType: AVCaptureDevice.DeviceType
        
        switch currentPosition {
        case .unspecified, .front:
            preferredPosition = .back
            preferredDeviceType = .builtInDualCamera
            
        case .back:
            preferredPosition = .front
            preferredDeviceType = .builtInTrueDepthCamera
            
        @unknown default:
            print("Unknown capture position. Defaulting to back, dual-camera.")
            preferredPosition = .back
            preferredDeviceType = .builtInDualCamera
        }
        
        let devices = self.videoDeviceDiscoverySession.devices
        var newVideoDevice: AVCaptureDevice? = nil
        
        // First, seek a device with both the preferred position and device type. Otherwise, seek a device with only the preferred position.
        if let device = devices.first(where: { $0.position == preferredPosition && $0.deviceType == preferredDeviceType }) {
            newVideoDevice = device
        } else if let device = devices.first(where: { $0.position == preferredPosition }) {
            newVideoDevice = device
        }
        
        self.session.removeInput(captureDeviceInput)
        
        return newVideoDevice
    }
}

// MARK: - ViewBootstrappable

extension CameraViewController: ViewBootstrappable {
    
    func configureViews() {
        view.addSubview(contactsCollectionView)
        contactsCollectionView.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width / 2)).isActive = true
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
                switch position {
                case .front:
                    self.sessionQueue.async {
                        self.configureSessionUpdate()
                    }
                default: break
                }
        }.store(in: &cancellables)
        
        Current.presentViewContollersSubject.sink { present in
                switch present {
                case .none:
                    
                    self.dismiss(animated: true)
                case .menu, .search: break
                    
                case .playback:
                    (0 ..< self.tapNotificationCount).forEach { _ in
                        self.playbackViewController.pushViewController(PlaybackViewController(), animated: false)
                    }
                    self.present(self.playbackViewController, animated: true) {}
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
        
        Current.mediaActionSubject.sink { action in
            switch action {
            case .none: break
            case .capturePhoto:
                self.previewView.flash()
                self.photoOutput.capturePhoto(with: self.photoSettings, delegate: self)
            case .captureVideoStart:
                if UIDevice.current.isMultitaskingSupported {
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                
                let movieFileOutputConnection = self.movieFileOutput.connection(with: .video)
                movieFileOutputConnection?.videoOrientation = .portrait
                
                let availableVideoCodecTypes = self.movieFileOutput.availableVideoCodecTypes
                
                if availableVideoCodecTypes.contains(.hevc) {
                    self.movieFileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: movieFileOutputConnection!)
                }
                
                
                let outputFileName = NSUUID().uuidString
                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                self.movieFileOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
            case .captureVideoEnd:
                self.movieFileOutput.stopRecording()
            }
        }.store(in: &cancellables)
    }
    
    internal func configureButtonTargets() {
        notificationButton.addTarget(self, action: #selector(showPlaybackAction), for: .touchUpInside)
    }
}
