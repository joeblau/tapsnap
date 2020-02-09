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
        addMetadataOutput()
        addPhotoOutput()
        addAudioDataOutput()
        addVideoDataOutput()
        
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
            let captureInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(captureInput) {
                session.addInput(captureInput)
            }
        } catch {
            fatalError("Could not create video device input")
        }
    }
    
    private func addMetadataOutput() {
        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
        } else {
            fatalError("Could not add metadata output to the session")
        }
    }
    
    private func addPhotoOutput() {
        let photoOutput = AVCapturePhotoOutput()
        if session.canAddOutput(photoOutput) {
            photoOutput.isHighResolutionCaptureEnabled = true
            session.addOutput(photoOutput)
        } else {
            fatalError("Could not add photo output to the session")
        }
    }
    
    private func addAudioDataOutput() {
        let audioDataOutput = AVCaptureAudioDataOutput()
        if session.canAddOutput(audioDataOutput) {
            
            session.addOutput(audioDataOutput)
        } else {
            fatalError("Could not add audio output to the session")
        }
    }
    
    
    private func addVideoDataOutput() {
        let videoDataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(videoDataOutput) {
            videoDataOutput.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey) : Int(kCVPixelFormatType_32BGRA)]
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            //             videoDataOutput.setSampleBufferDelegate(videoDelegate, queue: sessionQueue)
            session.addOutput(videoDataOutput)
        } else {
            fatalError("Could not add video output to session")
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
            case .capturePhoto: print("photo")
            case .captureVideoStart: print("start video")
            case .captureVideoEnd: print("stop video")
            }
        }.store(in: &cancellables)
    }
    
    internal func configureButtonTargets() {
        notificationButton.addTarget(self, action: #selector(showPlaybackAction), for: .touchUpInside)
    }
}
