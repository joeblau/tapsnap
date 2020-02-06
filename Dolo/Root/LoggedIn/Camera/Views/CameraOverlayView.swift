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
    
    let kButtonSize: CGFloat = 48
    let kButtonPadding: CGFloat = 8
    
    // Top left
    let menuButton = UIButton(type: .custom)
    let clearButton = UIButton(type: .custom)
    
    // Top right
    let notifictionsButton = UIButton(type: .custom)
    
    // Bottom right
    let musicButton = UIButton(type: .custom)
    let persistButton = UIButton(type: .custom)
    let locationButton = UIButton(type: .custom)
    let textboxButton = UIButton(type: .custom)
    let flipButton = UIButton(type: .custom)

    
    let canvasView = PKCanvasView(frame: .zero)
    let annotationTextView = TextOverlayView()
    var annotationTextViewWidth: NSLayoutConstraint!
    var annotationTextViewHeight: NSLayoutConstraint!
    
    let indeterminateProgressView = IndeterminateProgressView()
    let recordingProgressView = RecordProgressView()
    var drawingToolsViewHeight: CGFloat = 340

    var zoomScale: CGFloat = 1.0
    
    let topLeftStackView: UIStackView
    let topRightStackView: UIStackView
    let bottomRightStackView: UIStackView
    
    override init(frame: CGRect) {
        menuButton.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        menuButton.floatButton()
        
        clearButton.setImage(UIImage(systemName: "clear"), for: .normal)
        clearButton.floatButton()
        clearButton.isHidden = true
        
        notifictionsButton.setTitle("3", for: .normal)
        notifictionsButton.notification(diameter: kButtonSize)

        musicButton.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
        musicButton.setImage(UIImage(systemName: "speaker.fill"), for: .selected)
        musicButton.floatButton()
        
        persistButton.setImage(UIImage(systemName: "lock.slash.fill"), for: .normal)
        persistButton.setImage(UIImage(systemName: "lock.fill"), for: .selected)
        persistButton.floatButton()
        
        locationButton.setImage(UIImage(systemName: "location.slash.fill"), for: .normal)
        locationButton.setImage(UIImage(systemName: "location.fill"), for: .selected)
        locationButton.floatButton()
        
        textboxButton.setImage(UIImage(systemName: "keyboard"), for: .normal)
        textboxButton.floatButton()
        
        flipButton.setImage(UIImage(systemName: "arrow.2.circlepath"), for: .normal)
        flipButton.floatButton()
        
        do {
            topLeftStackView = UIStackView(arrangedSubviews: [menuButton, clearButton])
            topLeftStackView.translatesAutoresizingMaskIntoConstraints = false
            topLeftStackView.distribution = .fillEqually
            topLeftStackView.spacing = UIStackView.spacingUseSystem
            
            topRightStackView = UIStackView(arrangedSubviews: [notifictionsButton])
            topRightStackView.translatesAutoresizingMaskIntoConstraints = false
            topRightStackView.distribution = .fillEqually
            topRightStackView.spacing = UIStackView.spacingUseSystem
            
            bottomRightStackView = UIStackView(arrangedSubviews: [musicButton, persistButton, locationButton, textboxButton, flipButton])
            bottomRightStackView.translatesAutoresizingMaskIntoConstraints = false
            bottomRightStackView.distribution = .fillEqually
            bottomRightStackView.spacing = UIStackView.spacingUseSystem
        }
        
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.overrideUserInterfaceStyle = .light
        
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        canvasView.delegate = self
        self.process(authorization: CLLocationManager.authorizationStatus())
        
        do {
            configureButtonTargets()
            configureViews()
            configureGestureRecoginzers()
            configureStreams()
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        indeterminateProgressView.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.indeterminateProgressView.stopAnimating(withExitTransition: true, completion: nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Button Targets
    
    private func configureButtonTargets() {
        menuButton.addTarget(self, action: #selector(showMenuAction), for: .touchUpInside)
        musicButton.addTarget(self, action: #selector(toggleMusicAction), for: .touchUpInside)
        persistButton.addTarget(self, action: #selector(togglePersistAction), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(toggleLocationAction), for: .touchUpInside)
        notifictionsButton.addTarget(self, action: #selector(showPlayback), for: .touchUpInside)
        textboxButton.addTarget(self, action: #selector(showTextbox), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearEditingAction), for: .touchUpInside)
        flipButton.addTarget(self, action: #selector(flipCameraAction), for: .touchUpInside)
    }
    
    // MARK: - Configure Views
    
    private func configureViews() {
        [menuButton, clearButton, musicButton, persistButton, locationButton, textboxButton, flipButton].forEach { button in
            button.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
            button.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        }
        
        self.addSubview(recordingProgressView)
        recordingProgressView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        recordingProgressView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        recordingProgressView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        recordingProgressView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        self.addSubview(canvasView)
        canvasView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        canvasView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        canvasView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        canvasView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        self.addSubview(annotationTextView)
        annotationTextView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        annotationTextView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        annotationTextViewWidth  = annotationTextView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        annotationTextViewWidth.isActive = true
        annotationTextViewHeight = annotationTextView.heightAnchor.constraint(equalToConstant: 50)
        annotationTextViewHeight.isActive = true
        
        self.addSubview(topLeftStackView)
        topLeftStackView.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        topLeftStackView.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        topLeftStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: kButtonPadding).isActive = true
        topLeftStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: kButtonPadding).isActive = true
        
        self.addSubview(topRightStackView)
        topRightStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: kButtonSize).isActive = true
        topRightStackView.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        topRightStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -kButtonPadding).isActive = true
        topRightStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: kButtonPadding).isActive = true
        
        self.addSubview(bottomRightStackView)
        bottomRightStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: kButtonSize).isActive = true
        bottomRightStackView.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        bottomRightStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -kButtonPadding).isActive = true
        bottomRightStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -kButtonPadding).isActive = true
        
        addSubview(indeterminateProgressView)
        indeterminateProgressView.heightAnchor.constraint(equalToConstant: 4).isActive = true
        indeterminateProgressView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        indeterminateProgressView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        indeterminateProgressView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    private func configureGestureRecoginzers() {
        let dismissSingleTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardAction))
        dismissSingleTap.numberOfTapsRequired = 1
        addGestureRecognizer(dismissSingleTap)
        
        let flipCameraDoubleTap = UITapGestureRecognizer(target: self, action: #selector(flipCameraAction))
        flipCameraDoubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(flipCameraDoubleTap)
        
        let zoomTextRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(zoomText(gesture:)))
        addGestureRecognizer(zoomTextRecognizer)
        
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
                self.annotationTextView.inputView = nil
                self.annotationTextView.resignFirstResponder()
            case .keyboard:
                self.menuButton.isHidden = true
                
                self.canvasView.isUserInteractionEnabled = false
                
                self.annotationTextView.inputView?.removeFromSuperview()
                self.annotationTextView.inputView = nil
                self.annotationTextView.reloadInputViews()
            case .drawing:
                self.menuButton.isHidden = true
                
                self.canvasView.isUserInteractionEnabled = true
                
                self.annotationTextView.inputView = DrawingToolsView(height: self.drawingToolsViewHeight)
                self.annotationTextView.reloadInputViews()                

            case .music:
                self.menuButton.isHidden = true
                 
                 self.canvasView.isUserInteractionEnabled = true
                 
                 self.annotationTextView.inputView = MusicPlaybackView(height: self.drawingToolsViewHeight)
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
        
        Current.drawingColorSubject
            .sink { color in
                self.canvasView.tool = PKInkingTool(.pen, color: color.withAlphaComponent(0.8), width: 16)
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
    
    @objc private func toggleMusicAction() {
        musicButton.isSelected.toggle()
    }
    
    @objc private func togglePersistAction() {
        persistButton.isSelected.toggle()
    }
        
    @objc private func toggleLocationAction() {
        Current.locationManager.requestWhenInUseAuthorization()
    }
    
    @objc private func showPlayback() {
        Current.presentViewContollersSubject.value = .playback
    }
    
    @objc private func showMenuAction() {
         Current.presentViewContollersSubject.value = .menu
    }
    
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
    
    // MARK: - Gesture Recoginzers
    
    @objc private func dismissKeyboardAction() {
        annotationTextView.resignFirstResponder()
    }
    
    @objc private func flipCameraAction() {
        Current.activeCameraSubject.value = .back
    }
    
    @objc func zoomText(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            zoomScale = gesture.scale
        case .changed:
            print("chagne")
        default: break
        }
    }
    
    // MARK: - Helpers
    
    private func process(authorization status: CLAuthorizationStatus) {
        switch status {
        case .denied, .notDetermined, .restricted:
            locationButton.isSelected = false
        case .authorizedAlways, .authorizedWhenInUse:
            locationButton.isSelected = true
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

