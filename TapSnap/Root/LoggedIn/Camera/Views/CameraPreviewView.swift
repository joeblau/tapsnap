//
//  CameraPreviewView.swift
//  Dolo
//
//  Created by Joe Blau on 2/1/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit
import AVFoundation

final class CameraPreviewView: UIView {

    private let cameraOverlay = CameraOverlayView()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    init(session: AVCaptureSession) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resize
        layer.addSublayer(previewLayer)
        bootstrap()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 1, height: previewLayer.bounds.height)
    }
}

// MARK: - ViewBootstrappable

extension CameraPreviewView:  ViewBootstrappable {
    internal func configureViews() {
        addSubview(cameraOverlay)
        cameraOverlay.topAnchor.constraint(equalTo: topAnchor).isActive = true
        cameraOverlay.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        cameraOverlay.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        cameraOverlay.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
