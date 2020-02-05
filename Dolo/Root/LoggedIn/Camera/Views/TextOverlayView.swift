//
//  TextOverlayView.swift
//  Dolo
//
//  Created by Joe Blau on 2/4/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit
import Combine
class TextOverlayView: UITextView, UITextFieldDelegate {
    private var cancellables = Set<AnyCancellable>()

    private var isEditingText = false
    
    init() {
        super.init(frame: .zero, textContainer: nil)
        translatesAutoresizingMaskIntoConstraints = false
        textAlignment = .center
        backgroundColor = .clear
        sizeToFit()
        font = UIFont.systemFont(ofSize: 44, weight: .heavy)
        
        do {
//            configureStreams()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - Configure Streams
    
    private func configureStreams() {
        Current.editingSubject
            .sink { editState in
                self.isEditingText = editState == .keyboard
        }
        .store(in: &cancellables)
    }
    
    // MARK: - UITextFieldDelegate
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect { .zero }
    
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] { [UITextSelectionRect]() }
    
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
