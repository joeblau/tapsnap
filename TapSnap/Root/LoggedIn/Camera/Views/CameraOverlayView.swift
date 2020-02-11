// CameraOverlayView.swift
// Copyright (c) 2020 Tapsnap, LLC

import Combine
import CoreLocation
import PencilKit
import UIKit

final class CameraOverlayView: UIView {
    var cancellables = Set<AnyCancellable>()
    
    private let kButtonSize: CGFloat = 56
    private let kButtonPadding: CGFloat = 8
    
    // Bottom right
    private lazy var musicButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(systemName: "metronome"), for: .normal)
        b.floatButton()
        return b
    }()
    
    private let persistButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(systemName: "lock.slash"), for: .normal)
        b.setImage(UIImage(systemName: "lock"), for: .selected)
        b.floatButton()
        return b
    }()
    
    private lazy var locationButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(systemName: "location.slash"), for: .normal)
        b.setImage(UIImage(systemName: "location"), for: .selected)
        b.floatButton()
        return b
    }()
    
    private lazy var textboxButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(systemName: "keyboard"), for: .normal)
        b.floatButton()
        return b
    }()
    
    private lazy var flipButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
        b.floatButton()
        return b
    }()
    
    private lazy var canvasView: PKCanvasView = {
        let cv = PKCanvasView(frame: .zero)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isOpaque = false
        cv.backgroundColor = .clear
        cv.overrideUserInterfaceStyle = .light
        cv.delegate = self
        return cv
    }()
    
    private lazy var zoomTextRecognizer: UIPinchGestureRecognizer = {
        UIPinchGestureRecognizer(target: self, action: #selector(zoomTextAction(_:)))
    }()
    private lazy var rotateTextRecoinzer: UIRotationGestureRecognizer = {
        UIRotationGestureRecognizer(target: self, action: #selector(rotateTextAction(_:)))
    }()
    private lazy var panTextRecogizner: UIPanGestureRecognizer = {
        UIPanGestureRecognizer(target: self, action: #selector(panTextAction(_:)))
    }()
    
    
    private let annotationTextView = TextOverlayView()
    private var annotationTextViewWidth: NSLayoutConstraint!
    private var annotationTextViewHeight: NSLayoutConstraint!
    
    private let indeterminateProgressView = IndeterminateProgressView()
    private let recordingProgressView = RecordProgressView()
    private var drawingToolsViewHeight: CGFloat = 340
    
    private var zoomFactor: CGFloat = 1.0
    
    private lazy var bottomRightStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [musicButton, persistButton, locationButton, textboxButton, flipButton])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.distribution = .fillEqually
        sv.spacing = UIStackView.spacingUseSystem
        return sv
    }()
    
    override init(frame _: CGRect) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        process(authorization: CLLocationManager.authorizationStatus())
        
        bootstrap()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc private func showTextbox() {
        annotationTextView.inputAccessoryView = KeyboardAccessoryView()
        annotationTextView.becomeFirstResponder()
        annotationTextView.delegate = self
        Current.editingSubject.value = .keyboard
    }
    
    @objc private func togglePersistAction() {
        persistButton.isSelected.toggle()
        Current.lockMeidaBetweenSendSubject.send(persistButton.isSelected)
    }
    
    @objc private func toggleLocationAction() {
        Current.locationManager.requestWhenInUseAuthorization()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            drawingToolsViewHeight = keyboardRectangle.height
        }
    }
    
    // MARK: - Gesture Recoginzers
    
    @objc private func dismissKeyboardAction() {
        annotationTextView.resignFirstResponder()
    }
    
    @objc private func flipCameraAction() {
        Current.activeCameraSubject.value = (Current.activeCameraSubject.value == .back) ? .front : .back
    }
    
    @objc func zoomTextAction(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            annotationTextView.transform = annotationTextView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1.0
        default: break
        }
    }
    
    @objc func rotateTextAction(_ gesture: UIRotationGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            annotationTextView.transform = annotationTextView.transform.rotated(by: gesture.rotation)
            gesture.rotation = 0
        default: break
        }
    }
    
    @objc func panTextAction(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            let point = gesture.translation(in: annotationTextView)
            annotationTextView.transform = annotationTextView.transform.translatedBy(x: point.x, y: point.y)
            gesture.setTranslation(.zero, in: annotationTextView)
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
    
    func isCanvasClean() {
        let isclean = canvasView.drawing.bounds.isEmpty && annotationTextView.text.isEmpty
        switch isclean {
        case true: Current.topLeftNavBarSubject.value = .none
        case false: Current.topLeftNavBarSubject.value = .clear
        }
    }
    
    func isGestureStaackEnabled(for editState: EditState) {
        switch editState {
        case .keyboard:
            self.zoomTextRecognizer.isEnabled = true
            self.rotateTextRecoinzer.isEnabled = true
            self.panTextRecogizner.isEnabled = true
        case .clear, .drawing, .music:
            self.zoomTextRecognizer.isEnabled = false
            self.rotateTextRecoinzer.isEnabled = false
            self.panTextRecogizner.isEnabled = false
        case .none: break
        }
    }
}

extension CameraOverlayView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - ViewBootstrappable

extension CameraOverlayView: ViewBootstrappable {
    internal func configureButtonTargets() {
        persistButton.addTarget(self, action: #selector(togglePersistAction), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(toggleLocationAction), for: .touchUpInside)
        textboxButton.addTarget(self, action: #selector(showTextbox), for: .touchUpInside)
        flipButton.addTarget(self, action: #selector(flipCameraAction), for: .touchUpInside)
    }
    
    internal func configureViews() {
        [musicButton, persistButton, locationButton, textboxButton, flipButton].forEach { button in
            button.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
            button.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        }
        
        addSubview(recordingProgressView)
        recordingProgressView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        recordingProgressView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        recordingProgressView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        recordingProgressView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        addSubview(canvasView)
        canvasView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        canvasView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        canvasView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        canvasView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        addSubview(annotationTextView)
        annotationTextView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        annotationTextView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        annotationTextViewWidth = annotationTextView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        annotationTextViewWidth.isActive = true
        annotationTextViewHeight = annotationTextView.heightAnchor.constraint(equalToConstant: 50)
        annotationTextViewHeight.isActive = true
        
        addSubview(bottomRightStackView)
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
    
    internal func configureGestureRecoginzers() {
        let dismissSingleTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardAction))
        dismissSingleTap.numberOfTapsRequired = 1
        addGestureRecognizer(dismissSingleTap)
        
        let flipCameraDoubleTap = UITapGestureRecognizer(target: self, action: #selector(flipCameraAction))
        flipCameraDoubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(flipCameraDoubleTap)
        
        do { // Text flow
            zoomTextRecognizer.delegate = self
            addGestureRecognizer(zoomTextRecognizer)
            
            rotateTextRecoinzer.delegate = self
            addGestureRecognizer(rotateTextRecoinzer)
            
            panTextRecogizner.delegate = self
            addGestureRecognizer(panTextRecogizner)
        }
    }
    
    internal func configureStreams() {
        Current.editingSubject.sink { editState in
            switch editState {
            case .none:
                Current.topLeftNavBarSubject.value = .menu
                self.isGestureStaackEnabled(for: editState)
                
                self.canvasView.isUserInteractionEnabled = false
                self.annotationTextView.inputView = nil
                self.annotationTextView.resignFirstResponder()
            case .keyboard:
                self.isCanvasClean()
                self.isGestureStaackEnabled(for: editState)

                self.canvasView.isUserInteractionEnabled = false
                self.annotationTextView.inputView?.removeFromSuperview()
                self.annotationTextView.inputView = nil
                self.annotationTextView.reloadInputViews()
            case .drawing:
                self.isCanvasClean()
                self.isGestureStaackEnabled(for: editState)

                self.canvasView.isUserInteractionEnabled = true
                self.annotationTextView.inputView = DrawingToolsView(height: self.drawingToolsViewHeight)
                self.annotationTextView.reloadInputViews()
            case .music:
                self.isGestureStaackEnabled(for: editState)

                self.canvasView.isUserInteractionEnabled = false
                self.annotationTextView.inputView = MusicPlaybackView(height: self.drawingToolsViewHeight)
                self.annotationTextView.reloadInputViews()
            case .clear:
                self.annotationTextView.text = ""
                self.canvasView.drawing = PKDrawing()
                self.isCanvasClean()
            }
        }.store(in: &cancellables)
        
        Current.locationManager.didChangeAuthorization.sink { status in
            self.process(authorization: status)
        }.store(in: &cancellables)
        
        Current.drawingColorSubject.sink { color in
            self.canvasView.tool = PKInkingTool(.pen, color: color.withAlphaComponent(0.8), width: 16)
        }.store(in: &cancellables)
        
        Current.mediaActionSubject.sink { action in
            switch action {
            case .capturePhoto, .captureVideoEnd:
                self.indeterminateProgressView.startAnimating()
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.indeterminateProgressView.stopAnimating(withExitTransition: true, completion: nil)
                }
            default: break
            }
        }.store(in: &cancellables)
        
        Current.mediaActionSubject.sink { action in
            guard !Current.lockMeidaBetweenSendSubject.value else { return }
            
            switch action {
            case .capturePhoto, .captureVideoEnd:
                self.annotationTextView.text = ""
                self.canvasView.drawing = PKDrawing()
                self.isCanvasClean()
            case .captureVideoStart, .none: break
            }
        }.store(in: &cancellables)
        
        Current.musicSyncSubject.sink { shouldSync in
            self.musicButton.isEnabled = shouldSync
            
        }.store(in: &cancellables)
    }
}

extension CameraOverlayView: PKCanvasViewDelegate {
    func canvasViewDidBeginUsingTool(_: PKCanvasView) {
        Current.topLeftNavBarSubject.value = .clear
    }
}

extension CameraOverlayView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        annotationTextViewWidth.constant = textView.contentSize.width
        annotationTextViewHeight.constant = textView.contentSize.height
        if !textView.text.isEmpty {
            Current.topLeftNavBarSubject.value = .clear
        }
    }
}
