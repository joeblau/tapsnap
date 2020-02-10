// CameraPreviewView.swift
// Copyright (c) 2020 Tapsnap, LLC

import AVFoundation
import UIKit

final class CameraPreviewView: UIView {
    private let cameraOverlay = CameraOverlayView()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private lazy var flashView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.alpha = 0
        v.backgroundColor = .white
        return v
    }()

    init(session: AVCaptureSession) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreviewLayer.videoGravity = .resize
        layer.addSublayer(videoPreviewLayer)
        bootstrap()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer.frame = bounds
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 1, height: videoPreviewLayer.bounds.height)
    }

    func flash() {
        flashView.alpha = 1
        UIView.animate(withDuration: 0.25,
                       delay: 0, options: .curveEaseOut,
                       animations: {
                           self.flashView.alpha = 0
        }, completion: nil)
    }
}

// MARK: - ViewBootstrappable

extension CameraPreviewView: ViewBootstrappable {
    internal func configureViews() {
        addSubview(cameraOverlay)
        cameraOverlay.topAnchor.constraint(equalTo: topAnchor).isActive = true
        cameraOverlay.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        cameraOverlay.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        cameraOverlay.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        addSubview(flashView)
        flashView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        flashView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        flashView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        flashView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
