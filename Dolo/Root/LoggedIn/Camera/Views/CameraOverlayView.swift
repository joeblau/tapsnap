//
//  CameraOverlayView.swift
//  Dolo
//
//  Created by Joe Blau on 2/1/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit
import PencilKit

class CameraOverlayView: UIView {
    
    let kButtonSize: CGFloat = 56
    let kButtonPadding: CGFloat = 16
    let menuButton = UIButton(type: .system)
    let textboxButton = UIButton(type: .system)
    let flipButton = UIButton(type: .system)
    let cancelButton = UIButton(type: .system)
    let canvasView = PKCanvasView(frame: .zero)
    
    let textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    override init(frame: CGRect) {
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        menuButton.tintColor = .label
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        cancelButton.tintColor = .label
        cancelButton.isHidden = true
        
        textboxButton.translatesAutoresizingMaskIntoConstraints = false
        textboxButton.setImage(UIImage(systemName: "textbox"), for: .normal)
        textboxButton.tintColor = .label
        
        flipButton.translatesAutoresizingMaskIntoConstraints = false
        flipButton.setImage(UIImage(systemName: "arrow.2.circlepath"), for: .normal)
        flipButton.tintColor = .label
        
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        configureViews()
        configureGestureRecoginzers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure Views
    
    private func configureViews() {
        menuButton.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        textboxButton.addTarget(self, action: #selector(showTextbox), for: .touchUpInside)
        flipButton.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)

        self.addSubview(canvasView)
        canvasView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        canvasView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        canvasView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        canvasView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        self.addSubview(menuButton)
        menuButton.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        menuButton.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        menuButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: kButtonPadding).isActive = true
        menuButton.topAnchor.constraint(equalTo: topAnchor, constant: kButtonPadding).isActive = true
        
        self.addSubview(cancelButton)
        cancelButton.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -kButtonPadding).isActive = true
        cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: kButtonPadding).isActive = true
        
        self.addSubview(textboxButton)
        textboxButton.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        textboxButton.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        textboxButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: kButtonPadding).isActive = true
        textboxButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -kButtonPadding).isActive = true
        
        self.addSubview(flipButton)
        flipButton.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        flipButton.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        flipButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -kButtonPadding).isActive = true
        flipButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -kButtonPadding).isActive = true
        
        

    }
    
    private func configureGestureRecoginzers() {
        let dismissSingleTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissSingleTap.numberOfTapsRequired = 1
        addGestureRecognizer(dismissSingleTap)

        let flipCameraDoubleTap = UITapGestureRecognizer(target: self, action: #selector(flipCamera))
        flipCameraDoubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(flipCameraDoubleTap)
    }
    
    // MARK: - Actions
    
    @objc private func showTextbox() {
        let keyboardAccessoryView = KeyboardAccessoryView()
        keyboardAccessoryView.canvasView = canvasView
        self.addSubview(textfield)
        textfield.center = center
        textfield.inputAccessoryView = keyboardAccessoryView
        textfield.becomeFirstResponder()
    }
    
    @objc private func dismissKeyboard() {
        textfield.resignFirstResponder()
    }

    @objc private func flipCamera() {}

    @objc private func showMenu() {}
}

extension CameraOverlayView: PKToolPickerObserver {
    
}
