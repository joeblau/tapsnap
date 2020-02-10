//
//  AVCaptureSession+Extensions.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/9/20.
//

import AVFoundation

extension AVCaptureSession {
    // Session output
    static var photoOutput = AVCapturePhotoOutput()
    static var movieFileOutput = AVCaptureMovieFileOutput()
    static var captureDevice: AVCaptureDevice? = nil
    
    // MARK: - Public function
    
    func bootstrap() {
        beginConfiguration()
        inputs.forEach { removeInput($0) }
        
        backVideoDevice().map { addVideoInput(videoDevice: $0) }
        addAudioInput()
        addPhotoOutput()
        addMovieOutput()
        
        commitConfiguration()
    }
    
    func setCamera(to position: AVCaptureDevice.Position) {
        beginConfiguration()
        
        currentVideoCaptureDevice.map { removeInput($0) }
                
        switch position {
        case .front:
            frontVideoDevice().map { addVideoInput(videoDevice: $0) }
        default:
            backVideoDevice().map { addVideoInput(videoDevice: $0) }
        }
        commitConfiguration()
    }
    
    func zoom(with velocity: Float) {
        guard let device = AVCaptureSession.captureDevice else { return }
        do {
            try device.lockForConfiguration()
            let desiredZoomFactor = device.videoZoomFactor + CGFloat(atan2f(-velocity, 1337))
            device.videoZoomFactor = max(1.0, min(desiredZoomFactor, device.activeFormat.videoMaxZoomFactor))
            device.unlockForConfiguration()
        } catch {
            print("Can not lock capture device to zoom")
        }
    }
    
    // MARK: - Cameras
    
    private func frontVideoDevice() -> AVCaptureDevice? {
        if let trueDepth = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front) {
            AVCaptureSession.captureDevice = trueDepth
            return trueDepth
        } else if let wide = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            AVCaptureSession.captureDevice = wide
            return wide
        } else {
            return nil
        }
    }
    
    private func backVideoDevice() -> AVCaptureDevice? {
        if let tripple = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back) {
            AVCaptureSession.captureDevice = tripple
            return tripple
        } else if let dual = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            AVCaptureSession.captureDevice = dual
            return dual
        } else if let wide = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            AVCaptureSession.captureDevice = wide
            return wide
        } else {
            return nil
        }
    }
    
    // MARK: - Add Input Devices
    
    private func addVideoInput(videoDevice: AVCaptureDevice) {
        do {
            let videoCaptureInput = try AVCaptureDeviceInput(device: videoDevice)
            if canAddInput(videoCaptureInput) {
                addInput(videoCaptureInput)
            }
        } catch {
            fatalError("Could not create video device input")
        }
    }
    
    private func addAudioInput() {
        do {
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            if canAddInput(audioDeviceInput) {
                addInput(audioDeviceInput)
            }
        } catch {
            fatalError("Could not add audio input to session device input")
        }
    }
    
    // MARK: - Add Output Devices
    
    private func addPhotoOutput() {
        if canAddOutput(AVCaptureSession.photoOutput) {
            AVCaptureSession.photoOutput.isHighResolutionCaptureEnabled = true
            addOutput(AVCaptureSession.photoOutput)
        } else {
            fatalError("Could not add photo output to the session")
        }
    }
    
    private func addMovieOutput() {
        if canAddOutput(AVCaptureSession.movieFileOutput) {
            if let connection = AVCaptureSession.movieFileOutput.connection(with: .video),
                connection.isVideoStabilizationSupported  {
                connection.preferredVideoStabilizationMode = .auto
            }
            addOutput(AVCaptureSession.movieFileOutput)
        } else {
            fatalError("Could not add movie output to the session")
        }
    }
    
    // MARK: - Helpers
    
    private var currentVideoCaptureDevice: AVCaptureDeviceInput? {
        inputs.first { ($0 as? AVCaptureDeviceInput)?.device.hasMediaType(.video) ?? false } as? AVCaptureDeviceInput
    }
}
