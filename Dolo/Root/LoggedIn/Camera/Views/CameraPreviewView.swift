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
        
        addSubview(cameraOverlay)
        cameraOverlay.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        cameraOverlay.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        cameraOverlay.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        cameraOverlay.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
