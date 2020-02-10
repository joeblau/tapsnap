// TextOverlayView.swift
// Copyright (c) 2020 Tapsnap, LLC

import Combine
import UIKit

final class TextOverlayView: UITextView {
    private var cancellables = Set<AnyCancellable>()
    private var isEditingText = false

    init() {
        super.init(frame: .zero, textContainer: nil)
        translatesAutoresizingMaskIntoConstraints = false
        textAlignment = .center
        backgroundColor = .clear
        tintColor = .label
        sizeToFit()
        font = UIFont.systemFont(ofSize: 44, weight: .heavy)
        bootstrap()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ViewBootstrappable

extension TextOverlayView: ViewBootstrappable {
    internal func configureStreams() {
        Current.editingSubject
            .sink { editState in
                self.isEditingText = editState == .keyboard
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITextFieldDelegate

extension TextOverlayView: UITextFieldDelegate {
    override func point(inside _: CGPoint, with _: UIEvent?) -> Bool {
        false
    }

    override func selectionRects(for _: UITextRange) -> [UITextSelectionRect] { [UITextSelectionRect]() }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action {
        case #selector(UIResponderStandardEditActions.copy(_:)),
             #selector(UIResponderStandardEditActions.selectAll(_:)),
             #selector(UIResponderStandardEditActions.paste(_:)):
            return false
        default:
            break
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
