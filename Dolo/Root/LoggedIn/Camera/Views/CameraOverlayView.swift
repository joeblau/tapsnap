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
    let kButtonPadding: CGFloat = 0
    let menuButton = UIButton(type: .system)
    let cancelButton = UIButton(type: .system)
    
    let locationButton = UIButton(type: .system)
    let textboxButton = UIButton(type: .system)
    let flipButton = UIButton(type: .system)
    
    let canvasView = PKCanvasView(frame: .zero)
    let editActionStackView: UIStackView
    
    let textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    let recordingProgressView = RecordProgressView()
    
    var drawingToolsViewHeight: CGFloat = 340
    
    override init(frame: CGRect) {
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        menuButton.tintColor = .label
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        cancelButton.tintColor = .label
        cancelButton.isHidden = true
        
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.setImage(UIImage(systemName: "location.slash.fill"), for: .normal)
        locationButton.tintColor = .label
        
        textboxButton.translatesAutoresizingMaskIntoConstraints = false
        textboxButton.setImage(UIImage(systemName: "textbox"), for: .normal)
        textboxButton.tintColor = .label
        
        flipButton.translatesAutoresizingMaskIntoConstraints = false
        flipButton.setImage(UIImage(systemName: "arrow.2.circlepath"), for: .normal)
        flipButton.tintColor = .label
        
        editActionStackView = UIStackView(arrangedSubviews: [locationButton, textboxButton, flipButton])
        editActionStackView.translatesAutoresizingMaskIntoConstraints = false
        editActionStackView.distribution = .fillEqually
        
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.overrideUserInterfaceStyle = .light
        
        
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        configureViews()
        configureGestureRecoginzers()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Views
    
    private func configureViews() {
        self.addSubview(recordingProgressView)
        recordingProgressView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        recordingProgressView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        recordingProgressView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        recordingProgressView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        menuButton.addTarget(self, action: #selector(showMenuAction), for: .touchUpInside)
        textboxButton.addTarget(self, action: #selector(showTextbox), for: .touchUpInside)
        flipButton.addTarget(self, action: #selector(flipCameraAction), for: .touchUpInside)
        
        self.addSubview(canvasView)
        canvasView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        canvasView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        canvasView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        canvasView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        self.addSubview(menuButton)
        menuButton.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        menuButton.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        menuButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: kButtonPadding).isActive = true
        menuButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: kButtonPadding).isActive = true
        
        self.addSubview(cancelButton)
        cancelButton.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -kButtonPadding).isActive = true
        cancelButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: kButtonPadding).isActive = true
        
        self.addSubview(editActionStackView)
        let width = kButtonSize * CGFloat(editActionStackView.arrangedSubviews.count)
        editActionStackView.widthAnchor.constraint(equalToConstant: width).isActive = true
        editActionStackView.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        editActionStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -kButtonPadding).isActive = true
        editActionStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -kButtonPadding).isActive = true
        
        self.addSubview(textfield)
        textfield.center = center
    }
    
    private func configureGestureRecoginzers() {
        let dismissSingleTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardAction))
        dismissSingleTap.numberOfTapsRequired = 1
        addGestureRecognizer(dismissSingleTap)
        
        let flipCameraDoubleTap = UITapGestureRecognizer(target: self, action: #selector(flipCameraAction))
        flipCameraDoubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(flipCameraDoubleTap)
        
//        let zoomInOutPan = UIPanGestureRecognizer(target: self, action: #selector(zoomAction))
//        zoomInOutPan.maximumNumberOfTouches = 1
//        addGestureRecognizer(zoomInOutPan)

    }
    
    // MARK: - Actions
    
    @objc private func showTextbox() {
        
        textfield.inputAccessoryView = KeyboardAccessoryView(pressKeyboard: {
            self.textfield.inputView?.removeFromSuperview()
            self.textfield.inputView = nil
            self.textfield.reloadInputViews()
        }, pressDrawing: {
            self.textfield.inputView = DrawingToolsView(height: self.drawingToolsViewHeight,
                                                         selectedColor: { color in
                                                            self.canvasView.tool = PKInkingTool(.pen, color: color, width: 10)
            })
            self.textfield.reloadInputViews()
        }, pressDone: {
            self.textfield.resignFirstResponder()
        })
        textfield.becomeFirstResponder()
    }
    
    @objc private func dismissKeyboardAction() {
        textfield.resignFirstResponder()
    }
    
    @objc private func flipCameraAction() {}
    
    @objc private func showMenuAction() {}
    
    @objc private func zoomAction() {}

    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.drawingToolsViewHeight = keyboardRectangle.height
        }
    }
}

extension CameraOverlayView: PKToolPickerObserver {
    
}
