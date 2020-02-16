// AVCaptureSession+Extensions.swift
// Copyright (c) 2020 Tapsnap, LLC

import AVFoundation
import os.log

extension AVCaptureSession {
    static var photoOutput = AVCapturePhotoOutput()
    static var movieFileOutput = AVCaptureMovieFileOutput()
    private static var videoCaptureDevice: AVCaptureDevice?

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
        guard let device = AVCaptureSession.videoCaptureDevice else { return }
        do {
            try device.lockForConfiguration()
            let desiredZoomFactor = device.videoZoomFactor + CGFloat(atan2f(-velocity, 1337))
            device.videoZoomFactor = max(1.0, min(desiredZoomFactor, device.activeFormat.videoMaxZoomFactor))
            device.unlockForConfiguration()
        } catch {
             os_log("%@", log: .avFoundation, type: .error, error.localizedDescription)
        }
    }

    func disableBackgroundAudio() {
        beginConfiguration()
        removeAudioInput()
        commitConfiguration()
    }

    func enableBackgroundAudio() {
        beginConfiguration()
        addAudioInput()
        commitConfiguration()
    }

    // MARK: - Cameras

    private func frontVideoDevice() -> AVCaptureDevice? {
        if let trueDepth = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front) {
            AVCaptureSession.videoCaptureDevice = trueDepth
            return trueDepth
        } else if let wide = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            AVCaptureSession.videoCaptureDevice = wide
            return wide
        } else {
            return nil
        }
    }

    private func backVideoDevice() -> AVCaptureDevice? {
        if let tripple = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back) {
            AVCaptureSession.videoCaptureDevice = tripple
            return tripple
        } else if let dual = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            AVCaptureSession.videoCaptureDevice = dual
            return dual
        } else if let wide = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            AVCaptureSession.videoCaptureDevice = wide
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
            os_log("%@", log: .avFoundation, type: .error, error.localizedDescription)
        }
    }

    private func addAudioInput() {
        automaticallyConfiguresApplicationAudioSession = false
        do {
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)

            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.mixWithOthers, .allowBluetooth, .defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)

            if canAddInput(audioDeviceInput) {
                addInput(audioDeviceInput)
            }
        } catch {
            os_log("%@", log: .avFoundation, type: .error, error.localizedDescription)
        }
    }

    // MARK: - Add Output Devices

    private func addPhotoOutput() {
        switch canAddOutput(AVCaptureSession.photoOutput) {
        case true:
            AVCaptureSession.photoOutput.isHighResolutionCaptureEnabled = true
            addOutput(AVCaptureSession.photoOutput)
        case false:
            os_log("%@", log: .avFoundation, type: .error, "Could not add photo output to the session")
        }
    }

    private func addMovieOutput() {
        switch canAddOutput(AVCaptureSession.movieFileOutput) {
        case true:
            if let connection = AVCaptureSession.movieFileOutput.connection(with: .video),
                connection.isVideoStabilizationSupported {
                connection.preferredVideoStabilizationMode = .auto
            }
            addOutput(AVCaptureSession.movieFileOutput)
        case false:
            os_log("%@", log: .avFoundation, type: .error, "Could not add movie output to the session")
        }
    }

    // MARK: - Remove Capture Devices

    private func removeAudioInput() {
        guard let audioInput = currentAudioInputDevice else { return }
        removeInput(audioInput)

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient)
            try AVAudioSession.sharedInstance().setActive(false)
        } catch let error as NSError {
            os_log("%@", log: .avFoundation, type: .error, error.localizedDescription)
        }
    }

    // MARK: - Helpers

    private var currentVideoCaptureDevice: AVCaptureDeviceInput? {
        inputs.first { ($0 as? AVCaptureDeviceInput)?.device.hasMediaType(.video) ?? false } as? AVCaptureDeviceInput
    }

    private var currentAudioInputDevice: AVCaptureDeviceInput? {
        inputs.first { ($0 as? AVCaptureDeviceInput)?.device.hasMediaType(.audio) ?? false } as? AVCaptureDeviceInput
    }
}
