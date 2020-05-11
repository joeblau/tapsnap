// KeyboardAccessoryView.swift
// Copyright (c) 2020 Tapsnap, LLC

import Combine
import UIKit

final class KeyboardAccessoryView: UIVisualEffectView {
    private var cancellables = Set<AnyCancellable>()
    private let kAccessoryPadding: CGFloat = 4

    private lazy var accessoryStack: UIStackView = {
        let accessoryStack = UIStackView(arrangedSubviews: [textKeyboard, drawToolPicker, musicPlayback, doneButton])
        accessoryStack.translatesAutoresizingMaskIntoConstraints = false
        accessoryStack.distribution = .fillEqually
        accessoryStack.isLayoutMarginsRelativeArrangement = true
        accessoryStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: kAccessoryPadding, leading: kAccessoryPadding, bottom: kAccessoryPadding, trailing: kAccessoryPadding)
        accessoryStack.spacing = kAccessoryPadding
        return accessoryStack
    }()

    private lazy var textKeyboard: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(systemName: "textbox"), for: .normal)
        b.setBackgroundColor(color: .init(white: 1.0, alpha: 0.7), for: .selected)
        b.addTarget(self, action: #selector(pressKeyboardAction), for: .touchUpInside)
        b.keyboardAccessory()
        return b
    }()

    private lazy var drawToolPicker: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(systemName: "scribble"), for: .normal)
        b.setBackgroundColor(color: .init(white: 1.0, alpha: 0.7), for: .selected)
        b.addTarget(self, action: #selector(pressDrawingAction), for: .touchUpInside)
        b.keyboardAccessory()
        return b
    }()

    private lazy var musicPlayback: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(systemName: "music.note"), for: .normal)
        b.setBackgroundColor(color: .init(white: 1.0, alpha: 0.7), for: .selected)
        b.addTarget(self, action: #selector(musicPlaybackAction), for: .touchUpInside)
        b.keyboardAccessory()
        return b
    }()

    private lazy var doneButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle(L10n.titleDone, for: .normal)
        b.addTarget(self, action: #selector(pressDoneAction), for: .touchUpInside)
        b.keyboardAccessory(alpha: 0.15)
        return b
    }()

    private var currentSelected: UIButton?

    init() {
        super.init(effect: UIBlurEffect(style: .systemMaterial))
        translatesAutoresizingMaskIntoConstraints = false
        bootstrap()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIWindow().screen.bounds.width, height: 48)
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

extension KeyboardAccessoryView: ViewBootstrappable {
    internal func configureViews() {
        contentView.addSubview(accessoryStack)
        accessoryStack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        accessoryStack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        accessoryStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        accessoryStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    internal func configureStreams() {
        Current.editingSubject
            .sink { editState in
                switch editState {
                case .keyboard:
                    self.currentSelected?.isSelected = false
                    self.textKeyboard.isSelected = true
                    self.currentSelected = self.textKeyboard
                case .drawing:
                    self.currentSelected?.isSelected = false
                    self.drawToolPicker.isSelected = true
                    self.currentSelected = self.drawToolPicker
                case .music:
                    self.currentSelected?.isSelected = false

                    self.musicPlayback.isSelected = true
                    self.currentSelected = self.musicPlayback
                case .none, .clear:
                    return
                }
                self.textKeyboard.tintColor = self.textKeyboard.isSelected ? .systemBackground : .label
                self.drawToolPicker.tintColor = self.drawToolPicker.isSelected ? .systemBackground : .label
                self.musicPlayback.tintColor = self.musicPlayback.isSelected ? .systemBackground : .label
            }
            .store(in: &cancellables)
    }
}
