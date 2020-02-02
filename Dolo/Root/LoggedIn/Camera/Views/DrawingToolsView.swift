//
//  DrawingToolsView.swift
//  Dolo
//
//  Created by Joe Blau on 2/2/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

class DrawingToolsView: UIVisualEffectView {

    let intrinsicHeight: CGFloat
    let colorButtons: [UIButton]
    let colorPickerStackView: UIStackView
    
    var selectColorClosure: ((_ color: UIColor) -> Void)?

    
    init(height: CGFloat,
         selectedColor: ((_ color: UIColor) -> Void)? = nil) {
        selectColorClosure = selectedColor
        
        intrinsicHeight = height - 48.0
        colorButtons = [UIColor.label,
                        UIColor.red,
                        UIColor.orange,
                        UIColor.yellow,
                        UIColor.green,
                        UIColor.blue,
                        UIColor.magenta,
                        UIColor.cyan]
            .enumerated()
            .map { (offset: Int, color: UIColor) -> UIButton in
                let button = UIButton(type: .system)
                button.layer.cornerRadius = 20
                button.backgroundColor = color
                button.tag = offset
                return button
        }

        colorPickerStackView = UIStackView(arrangedSubviews: colorButtons)
        colorPickerStackView.translatesAutoresizingMaskIntoConstraints = false
        colorPickerStackView.distribution = .fillEqually
        colorPickerStackView.spacing = UIStackView.spacingUseSystem
        
        super.init(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        
        colorButtons.forEach { button in
            button.addTarget(self, action: #selector(selectColorAction), for: .touchUpInside)
        }
        translatesAutoresizingMaskIntoConstraints = false
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Views
    
    private func configureViews() {
        contentView.addSubview(colorPickerStackView)
        colorPickerStackView.topAnchor.constraint(equalTo: topAnchor, constant: 32).isActive = true
        colorPickerStackView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        colorPickerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        colorPickerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIWindow().screen.bounds.width,
                      height: intrinsicHeight)
    }
    
    // MARK: - Actions
    
    @objc private func selectColorAction(sender: UIButton) {
        guard let color = sender.backgroundColor else {
            return
        }
        selectColorClosure?(color)
        self.colorButtons.forEach { button in
            button.layer.borderWidth = 0
        }
        sender.layer.borderWidth = 4
    }
}
