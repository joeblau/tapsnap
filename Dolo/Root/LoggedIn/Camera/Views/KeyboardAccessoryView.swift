//
//  KeyboardAccessoryView.swift
//  Dolo
//
//  Created by Joe Blau on 2/1/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit
import Combine

final class KeyboardAccessoryView: UIVisualEffectView {
    private var cancellables = Set<AnyCancellable>()
    let kAccessoryPadding: CGFloat = 4
    let accessoryStack: UIStackView
    let textKeyboard = UIButton(type: .custom)
    let drawToolPicker = UIButton(type: .custom)
    let musicPlayback = UIButton(type: .custom)
    let doneButton = UIButton(type: .custom)
    var currentSelected: UIButton?
    
    init() {
        textKeyboard.setImage(UIImage(systemName: "textbox"), for: .normal)
        textKeyboard.setBackgroundColor(color: .label, for: .selected)
        textKeyboard.keyboardAccessory()
        
        drawToolPicker.setImage(UIImage(systemName: "scribble"), for: .normal)
        drawToolPicker.setBackgroundColor(color: .label, for: .selected)
        drawToolPicker.keyboardAccessory()
        
        musicPlayback.setImage(UIImage(systemName: "music.note"), for: .normal)
        musicPlayback.setBackgroundColor(color: .label, for: .selected)
        musicPlayback.keyboardAccessory()
        
        doneButton.setTitle("Done", for: .normal)
        doneButton.keyboardAccessory(alpha: 0.15)
        
        accessoryStack = UIStackView(arrangedSubviews: [textKeyboard, drawToolPicker, musicPlayback, doneButton])
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
            configureStreams()
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
        musicPlayback.addTarget(self, action: #selector(musicPlaybackAction), for: .touchUpInside)
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
    
    // MARK: - Configure Streams
    
    private func configureStreams() {
        Current.editingSubject
            .sink { editState in

                self.currentSelected?.isSelected = false
                switch editState {
                case .keyboard:
                    self.textKeyboard.isSelected = true
                    self.currentSelected = self.textKeyboard
                case .drawing:
                    self.drawToolPicker.isSelected = true
                    self.currentSelected = self.drawToolPicker
                case .music:
                    self.musicPlayback.isSelected = true
                    self.currentSelected = self.musicPlayback
                case  .none, .clear:
                    return
                }
                self.textKeyboard.tintColor = self.textKeyboard.isSelected ? .systemBackground : .label
                self.drawToolPicker.tintColor = self.drawToolPicker.isSelected ? .systemBackground : .label
                self.musicPlayback.tintColor = self.musicPlayback.isSelected ? .systemBackground : .label
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    @objc private func pressKeyboardAction() {
        Current.editingSubject.value = .keyboard
    }
    
    @objc private func pressDrawingAction() {
        Current.editingSubject.value = .drawing
    }
    
    @objc private func musicPlaybackAction() {
        Current.editingSubject.value = .music
    }
    
    @objc private func pressDoneAction() {
        Current.editingSubject.value = .none
    }
    
}
