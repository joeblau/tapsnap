//
//  CameraPreviewView.swift
//  Dolo
//
//  Created by Joe Blau on 2/1/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPreviewView: UIView {

    let cameraOverlay = CameraOverlayView()

    var previewLayer: AVCaptureVideoPreviewLayer!
    
    init(session: AVCaptureSession) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resize
        layer.addSublayer(previewLayer)
        
        do {
            configureViews()
        }
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
    // MARK: - Configure Views
    
    private func configureViews() {
        addSubview(cameraOverlay)
        cameraOverlay.topAnchor.constraint(equalTo: topAnchor).isActive = true
        cameraOverlay.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        cameraOverlay.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        cameraOverlay.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
