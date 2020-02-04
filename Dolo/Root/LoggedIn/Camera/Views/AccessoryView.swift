//
//  KeyboardAccessoryView.swift
//  Dolo
//
//  Created by Joe Blau on 2/1/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

final class KeyboardAccessoryView: UIVisualEffectView {
    
    let kAccessoryPadding: CGFloat = 4
    let accessoryStack: UIStackView
    let textKeyboard = UIButton(type: .system)
    let drawToolPicker = UIButton(type: .system)
    let musicSetup = UIButton(type: .system)
    let doneButton = UIButton(type: .system)
    
    init() {
        textKeyboard.setImage(UIImage(systemName: "textbox"), for: .normal)
        textKeyboard.keyboardAccessory()
        
        drawToolPicker.setImage(UIImage(systemName: "scribble"), for: .normal)
        drawToolPicker.keyboardAccessory()
        
        musicSetup.setImage(UIImage(systemName: "music.note"), for: .normal)
        musicSetup.keyboardAccessory()
        
        doneButton.setTitle("Done", for: .normal)
        doneButton.keyboardAccessory(alpha: 0.15)
        
        accessoryStack = UIStackView(arrangedSubviews: [textKeyboard, drawToolPicker, musicSetup, doneButton])
        accessoryStack.translatesAutoresizingMaskIntoConstraints = false
        accessoryStack.distribution = .fillEqually
        accessoryStack.isLayoutMarginsRelativeArrangement = true
        accessoryStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: kAccessoryPadding, leading: kAccessoryPadding, bottom: kAccessoryPadding, trailing: kAccessoryPadding)
        accessoryStack.spacing = kAccessoryPadding
        
        super.init(effect: UIBlurEffect(style: .systemMaterial))
        translatesAutoresizingMaskIntoConstraints = false
        
        do {
            configureButtonTargets()
            configureViews()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIWindow().screen.bounds.width, height: 48)
    }
    
    // MARK: - Configure Button Targets
    
    private func configureButtonTargets() {
        textKeyboard.addTarget(self, action: #selector(pressKeyboardAction), for: .touchUpInside)
        drawToolPicker.addTarget(self, action: #selector(pressDrawingAction), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(pressDoneAction), for: .touchUpInside)
    }
    
    // MARK: - Configure Views
    
    private func configureViews() {
        contentView.addSubview(accessoryStack)
        accessoryStack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        accessoryStack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        accessoryStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        accessoryStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    // MARK: - Actions
    
    @objc private func pressKeyboardAction() {
        Current.editingSubject.value = .keyboard
    }
    
    @objc private func pressDrawingAction() {
        Current.editingSubject.value = .drawing
    }
    
    @objc private func pressDoneAction() {
        Current.editingSubject.value = .none
    }
    
}
