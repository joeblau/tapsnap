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

    let itemsInSection = [15]
    var previewView: CameraPreviewView?
    let session = AVCaptureSession()
    let sessionQueue = DispatchQueue(label: "session queue")
    
    let contactsCollectionView = ContactsCollectionView()
    let contactEditorView = ContactEditorView()
    var cancellables = Set<AnyCancellable>()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewView = CameraPreviewView(session: session)
        
        contactsCollectionView.register(ContactCollectionViewCell.self,
                                             forCellWithReuseIdentifier: ContactCollectionViewCell.id)
        contactsCollectionView.isPagingEnabled = true
        contactsCollectionView.dataSource = self
        
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
        
        view.addSubview(contactEditorView)
        contactEditorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        contactEditorView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contactEditorView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contactEditorView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(contactsCollectionView)
        contactsCollectionView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        contactsCollectionView.bottomAnchor.constraint(equalTo: contactEditorView.topAnchor).isActive = true
        contactsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contactsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        guard let previewView = previewView else { return }
        view.addSubview(previewView)
        previewView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: contactsCollectionView.topAnchor).isActive = true
        previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    // MARK: - Actions
    
    @objc func editContacts() {
        
    }
    
    @objc func searchContacts() {
        
    }
    
    // MARK: - Private
    
    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .vga640x480
        
        session.inputs.forEach { captureInnput in
            session.removeInput(captureInnput)
        }
        
        addCaptureDeviceInput()
        addMetadataOutput()
        addPhotoOutput()
        addVideoDataOutput()

        session.commitConfiguration()
    }
    
    private func addCaptureDeviceInput() {
         do {
             let types: [AVCaptureDevice.DeviceType] = [.builtInDualCamera,
                                                        .builtInTelephotoCamera,
                                                        .builtInWideAngleCamera]
             guard let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: types,
                                                                      mediaType: .video,
                                                                      position: .back)
                 .devices
                 .first else {
                     return
             }
             
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
    
    
}
