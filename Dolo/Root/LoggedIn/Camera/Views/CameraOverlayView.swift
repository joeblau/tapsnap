//
//  CameraOverlayView.swift
//  Dolo
//
//  Created by Joe Blau on 2/1/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit
import PencilKit
import Combine
import CoreLocation

class CameraOverlayView: UIView {
    var cancellables = Set<AnyCancellable>()

    let kButtonSize: CGFloat = 56
    let kButtonPadding: CGFloat = 8
    let menuButton = UIButton(type: .system)
    let clearButton = UIButton(type: .system)
    
    let locationButton = UIButton(type: .system)
    let textboxButton = UIButton(type: .system)
    let flipButton = UIButton(type: .system)
    
    let canvasView = PKCanvasView(frame: .zero)
    let editActionStackView: UIStackView
    
    let annotationTextView = UITextView()
    var annotationTextViewWidth: NSLayoutConstraint!
    var annotationTextViewHeight: NSLayoutConstraint!

    let recordingProgressView = RecordProgressView()
    
    var drawingToolsViewHeight: CGFloat = 340
    
    override init(frame: CGRect) {
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        menuButton.tintColor = .label
        
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        clearButton.tintColor = .label
        clearButton.isHidden = true
        
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
        editActionStackView.spacing = UIStackView.spacingUseSystem
        
        annotationTextView.translatesAutoresizingMaskIntoConstraints = false
        annotationTextView.textAlignment = .center
        annotationTextView.backgroundColor = .clear
        annotationTextView.sizeToFit()
        annotationTextView.font = UIFont.systemFont(ofSize: 44, weight: .heavy)
        
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.overrideUserInterfaceStyle = .dark
        
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        canvasView.delegate = self
        self.process(authorization: CLLocationManager.authorizationStatus())

        menuButton.addTarget(self, action: #selector(showMenuAction), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(showLocationAction), for: .touchUpInside)
        textboxButton.addTarget(self, action: #selector(showTextbox), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearEditingAction), for: .touchUpInside)
        flipButton.addTarget(self, action: #selector(flipCameraAction), for: .touchUpInside)

        
        
        configureViews()
        configureGestureRecoginzers()
        configureStreams()
        
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

        locationButton.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        locationButton.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true

        textboxButton.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        textboxButton.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        
        flipButton.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        flipButton.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        
        self.addSubview(recordingProgressView)
        recordingProgressView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        recordingProgressView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        recordingProgressView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        recordingProgressView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        self.addSubview(annotationTextView)
        annotationTextView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        annotationTextView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        annotationTextViewWidth  = annotationTextView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        annotationTextViewWidth.isActive = true
        annotationTextViewHeight = annotationTextView.heightAnchor.constraint(equalToConstant: 50)
        annotationTextViewHeight.isActive = true
        
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
        
        self.addSubview(clearButton)
        clearButton.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        clearButton.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        clearButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: kButtonPadding).isActive = true
        clearButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: kButtonPadding).isActive = true
        
        self.addSubview(editActionStackView)
        let width = kButtonSize * CGFloat(editActionStackView.arrangedSubviews.count)
        editActionStackView.widthAnchor.constraint(lessThanOrEqualToConstant: width).isActive = true
        editActionStackView.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        editActionStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -kButtonPadding).isActive = true
        editActionStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -kButtonPadding).isActive = true
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
    
    private func configureStreams() {
            Current.editingSubject.sink { editState in
                switch editState {
                case .none:
                    self.menuButton.isHidden = false
                    self.clearButton.isHidden = true
                    self.canvasView.isUserInteractionEnabled = false
                    self.annotationTextView.resignFirstResponder()
                case .drawing:
                    self.menuButton.isHidden = true
                    
                    self.canvasView.isUserInteractionEnabled = true
                    
                    self.annotationTextView.inputView = DrawingToolsView(height: self.drawingToolsViewHeight,
                                                                 selectedColor: { color in
                                                                    self.canvasView.tool = PKInkingTool(.pen, color: color, width: 10)
                    })
                    self.annotationTextView.reloadInputViews()
                case .keyboard:
                    self.menuButton.isHidden = true
                    
                    self.canvasView.isUserInteractionEnabled = false

                    self.annotationTextView.inputView?.removeFromSuperview()
                    self.annotationTextView.inputView = nil
                    self.annotationTextView.reloadInputViews()
                case .clear:
                    self.clearButton.isHidden = true
                    self.annotationTextView.text = ""
                    self.canvasView.drawing = PKDrawing()
                }
            }
        .store(in: &cancellables)
        
        Current.locationManager
            .didChangeAuthorization
            .sink { status in
            self.process(authorization: status)
        }
        .store(in: &cancellables)
    }
    // MARK: - Actions
    
    @objc private func showTextbox() {
        processClearButton()
        annotationTextView.inputAccessoryView = KeyboardAccessoryView()
        annotationTextView.becomeFirstResponder()
        annotationTextView.delegate = self
        Current.editingSubject.value = .keyboard
    }
    
    @objc private func dismissKeyboardAction() {
        annotationTextView.resignFirstResponder()
    }
    
    @objc private func showLocationAction() {
        Current.locationManager.requestWhenInUseAuthorization()
    }
    
    @objc private func flipCameraAction() {
        Current.activeCameraSubject.value = .back
    }
    
    @objc private func showMenuAction() {}
    
    @objc private func zoomAction() {}
    
    @objc private func clearEditingAction() {
        Current.editingSubject.value = .clear
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.drawingToolsViewHeight = keyboardRectangle.height
        }
    }
    
    // MARK: - Helpers
    
    private func process(authorization status: CLAuthorizationStatus) {
        switch status {
        case .denied, .notDetermined, .restricted:
            locationButton.isHidden = false
        case .authorizedAlways, .authorizedWhenInUse:
            locationButton.isHidden = true
        @unknown default:
            fatalError("Unknown CLLocationManager.authorizationStatus")
        }
    }
    
    private func processClearButton() {
        clearButton.isHidden = (canvasView.drawing.bounds.isEmpty && annotationTextView.text.isEmpty)
    }
}

extension CameraOverlayView: PKCanvasViewDelegate {
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        processClearButton()
    }
}

extension CameraOverlayView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        annotationTextViewWidth.constant = textView.contentSize.width
        annotationTextViewHeight.constant = textView.contentSize.height
        processClearButton()
    }
}

