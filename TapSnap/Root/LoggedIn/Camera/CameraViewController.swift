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

class CameraViewController: UIViewController {
    let kButtonSize: CGFloat = 48
    
    // Top left
    let menuButton = UIButton(type: .custom)
    let clearButton = UIButton(type: .custom)
    
    // Top right
    let notifictionsButton = UIButton(type: .custom)
    
    let itemsInSection = [15]
    var previewView: CameraPreviewView?
    let session = AVCaptureSession()
    let sessionQueue = DispatchQueue(label: "session queue")
    
    let contactPageControl = UIPageControl()
    let contactsCollectionView = ContactsCollectionView()
    
    weak var search: UINavigationController? {
        let nav = UINavigationController(rootViewController: SearchContactsViewController())
        return nav
    }
    
    var cancellables = Set<AnyCancellable>()
    
    weak var playback: UINavigationController? {
        let nav = UINavigationController(rootViewController: PlaybackViewController())
        nav.modalPresentationStyle = .overCurrentContext
        
        return nav
    }
    
    init() {
        menuButton.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        menuButton.floatButton()
        
        clearButton.setImage(UIImage(systemName: "clear"), for: .normal)
        clearButton.floatButton()
        
        notifictionsButton.setTitle("8", for: .normal)
        notifictionsButton.notification(diameter: 20)
        
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: notifictionsButton)
        previewView = CameraPreviewView(session: session)
        
        
        do {
            let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: nil)
            editButton.tintColor = .label
            let recentsButton = UIBarButtonItem(image: UIImage(systemName: "clock", withConfiguration: UIImage.SymbolConfiguration(scale: .small)),
                                                style: .plain,
                                                target: nil, action: nil)
            recentsButton.tintColor = .white
            
            let pageControlButton = UIBarButtonItem(customView: contactPageControl)
            contactPageControl.numberOfPages = Int(ceil(Double(itemsInSection[0]) / 8.0))
            
            let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchContactsAction))
            searchButton.tintColor = .label

            let smallSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            smallSpacer.width = 40
            
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            toolbarItems = [editButton, spacer, pageControlButton, spacer,  searchButton]
        }
        contactsCollectionView.register(ContactCollectionViewCell.self,
                                             forCellWithReuseIdentifier: ContactCollectionViewCell.id)
        contactsCollectionView.isPagingEnabled = true
        contactsCollectionView.dataSource = self
        contactsCollectionView.delegate = self
        contactsCollectionView.bounces = false
        
        do {
            configureButtonTargets()
            configureStreams()
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.addSubview(contactsCollectionView)
        contactsCollectionView.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width / 2)).isActive = true
        contactsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        contactsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contactsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        guard let previewView = previewView else { return }
        view.addSubview(previewView)
        previewView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: contactsCollectionView.topAnchor).isActive = true
        previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    // MARK: - Configure Views
    
    private func configureViews() {
        [menuButton, clearButton].forEach { button in
            button.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
            button.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        }
    }
    // MARK: - Configure Streams
    
    private func configureStreams() {
        Current.activeCameraSubject
            .sink { position in
                if position != .front {
                    
                    self.sessionQueue.async {
                        self.configureSessionUpdate()
                    }
                }
        }.store(in: &cancellables)
        
        Current.presentViewContollersSubject
            .sink { present in
                switch present {
                case .none:
                    self.dismiss(animated: true)
                case .menu, .search: break
                    
                case .playback:
                    guard let playback = self.playback else { return }
                    self.present(playback, animated: true) {}
                }
        }
        .store(in: &cancellables)
        
        Current.topLeftNavBarSubject
            .sink { leftNavBarItem in
                switch leftNavBarItem {
                case .none:
                    self.navigationItem.leftBarButtonItem = nil
                case .menu:
                    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.menuButton)
                case .clear:
                    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.clearButton)
                }
        }
        .store(in: &cancellables)
        
        
        
    }
    // MARK: - Configure Button Targets
    
    private func configureButtonTargets() {
        menuButton.addTarget(self, action: #selector(showMenuAction), for: .touchUpInside)
        notifictionsButton.addTarget(self, action: #selector(showPlaybackAction), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearEditingAction), for: .touchUpInside)
    }
    
    
    // MARK: - Actions
    
    @objc private func showPlaybackAction() {
        Current.presentViewContollersSubject.value = .playback
    }
    
    @objc private func showMenuAction() {
         Current.presentViewContollersSubject.value = .menu
    }
    
    @objc private func clearEditingAction() {
        Current.editingSubject.value = .clear
    }
    
    @objc func editContacts() {}
    
    @objc func searchContactsAction() {
        guard let search = search else { return }
        present(search, animated: true, completion: nil)
    }
    
    // MARK: - Private
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
                                                                               mediaType: .video, position: .unspecified)
    
    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .vga640x480
        
        session.inputs.forEach { captureInnput in
            session.removeInput(captureInnput)
        }
        if let videoDevice = initailzeCamera() {
            addCaptureDeviceInput(videoDevice: videoDevice)
        }
        addMetadataOutput()
        addPhotoOutput()
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
             session.addOutput(photoOutput)
             photoOutput.isHighResolutionCaptureEnabled = true
         } else {
             fatalError("Could not add photo output to the session")
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
