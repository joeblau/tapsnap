// AVCaptureSession+Extensions.swift
// Copyright (c) 2020 Tapsnap, LLC

import AVFoundation
import os.log

extension AVCaptureSession {
    static var photoOutput: AVCapturePhotoOutput = {
        let o = AVCapturePhotoOutput()
        o.isHighResolutionCaptureEnabled = true
        o.connection(with: .video)?.videoOrientation = .landscapeLeft
        return o
    }()

    static var movieFileOutput: AVCaptureMovieFileOutput = {
        let o = AVCaptureMovieFileOutput()
        o.connection(with: .video)?.preferredVideoStabilizationMode = .auto
        return o
    }()

    private static var videoCaptureDevice: AVCaptureDevice?

    // MARK: - Public function

    func bootstrap() {
        beginConfiguration()
        inputs.forEach { removeInput($0) }

        addVideo(capture: backVideoDevice())
        addAudioInput()
        addPhotoOutput()
        addMovieOutput()

        commitConfiguration()
    }

    func setCamera(to position: AVCaptureDevice.Position) {
        beginConfiguration()

        currentVideoCaptureDevice.map { removeInput($0) }

        switch position {
        case .front: addVideo(capture: frontVideoDevice())
        default: addVideo(capture: backVideoDevice())
        }
        commitConfiguration()
        initZoom()
    }

    func initZoom() {
        guard let device = AVCaptureSession.videoCaptureDevice,
            device == AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back) else { return }
        do {
            defer {
                device.unlockForConfiguration()
            }
            try device.lockForConfiguration()
            switch device {
            case AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back):
                device.videoZoomFactor = device.virtualDeviceSwitchOverVideoZoomFactors.first as! CGFloat
            default: break
            }
        } catch {
            os_log("%@", log: .avFoundation, type: .error, error.localizedDescription)
        }
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

    private func addVideo(capture device: AVCaptureDevice?) {
        device.map { currentDevice in
            defer {
                currentDevice.unlockForConfiguration()
            }
            do {
                try currentDevice.lockForConfiguration()
                if currentDevice.isFocusModeSupported(.continuousAutoFocus) {
                    currentDevice.focusMode = .continuousAutoFocus
                }
                if currentDevice.isGeometricDistortionCorrectionSupported {
                    currentDevice.isGeometricDistortionCorrectionEnabled = true
                }
                if currentDevice.isLowLightBoostSupported {
                    currentDevice.automaticallyEnablesLowLightBoostWhenAvailable = true
                }
                addVideoInput(videoDevice: currentDevice)
            } catch {
                os_log("%@", log: .avFoundation, type: .error, error.localizedDescription)
            }
        }
    }

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
        if let triple = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back) {
            AVCaptureSession.videoCaptureDevice = triple
            return triple
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
            guard let audioDevice = AVCaptureDevice.default(for: .audio) else { return }
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)

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
            addOutput(AVCaptureSession.photoOutput)
        case false:
            os_log("%@", log: .avFoundation, type: .error, "Could not add photo output to the session")
        }
    }

    private func addMovieOutput() {
        switch canAddOutput(AVCaptureSession.movieFileOutput) {
        case true:
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
