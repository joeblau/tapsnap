//
//  CameraPreviewView.swift
//  Dolo
//
//  Created by Joe Blau on 2/1/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

class CameraPreviewView: UIView {

    let cameraOverlay = CameraOverlayView()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .red
        translatesAutoresizingMaskIntoConstraints = false
        
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Views
    
    private func configureViews() {
        addSubview(cameraOverlay)
        cameraOverlay.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        cameraOverlay.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        cameraOverlay.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        cameraOverlay.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

}
