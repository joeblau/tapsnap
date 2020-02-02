//
//  KeyboardAccessoryView.swift
//  Dolo
//
//  Created by Joe Blau on 2/1/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit
import PencilKit

class KeyboardAccessoryView: UIVisualEffectView {

    let kAccessoryPadding: CGFloat = 4
    let accessoryStack: UIStackView
    let textKeyboard = UIButton(type: .system)
    let drawToolPicker = UIButton(type: .system)
    var canvasView: PKCanvasView?
    
    override init(effect: UIVisualEffect?) {
        textKeyboard.translatesAutoresizingMaskIntoConstraints = false
        textKeyboard.setImage(UIImage(systemName: "keyboard"), for: .normal)
        textKeyboard.tintColor = .label
        textKeyboard.backgroundColor = UIColor.label.withAlphaComponent(0.3)
        textKeyboard.layer.cornerRadius = 8

        drawToolPicker.translatesAutoresizingMaskIntoConstraints = false
        drawToolPicker.setImage(UIImage(systemName: "pencil.and.outline"), for: .normal)
        drawToolPicker.tintColor = .label
        drawToolPicker.backgroundColor = UIColor.label.withAlphaComponent(0.3)
        drawToolPicker.layer.cornerRadius = 8

        accessoryStack = UIStackView(arrangedSubviews: [textKeyboard, drawToolPicker])
        accessoryStack.translatesAutoresizingMaskIntoConstraints = false
        accessoryStack.distribution = .fillEqually
        accessoryStack.isLayoutMarginsRelativeArrangement = true
        accessoryStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: kAccessoryPadding, leading: kAccessoryPadding, bottom: kAccessoryPadding, trailing: kAccessoryPadding)
        accessoryStack.spacing = kAccessoryPadding
        
        super.init(effect: UIBlurEffect(style: .regular))
        textKeyboard.addTarget(self, action: #selector(showKeyboard), for: .touchUpInside)
        drawToolPicker.addTarget(self, action: #selector(showDrawTool), for: .touchUpInside)

        translatesAutoresizingMaskIntoConstraints = false
        configureViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIWindow().screen.bounds.width, height: 48)
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
    
    @objc private func showKeyboard() {}

    @objc private func showDrawTool() {
        guard let window = window,
            let toolPicker = PKToolPicker.shared(for: window),
            let canvasView = canvasView else {
            return
        }
        toolPicker.addObserver(canvasView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        canvasView.becomeFirstResponder()
    }

}
