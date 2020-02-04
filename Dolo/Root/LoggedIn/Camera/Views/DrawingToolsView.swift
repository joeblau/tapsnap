//
//  DrawingToolsView.swift
//  Dolo
//
//  Created by Joe Blau on 2/2/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

final class DrawingToolsView: UIVisualEffectView {

    private let intrinsicHeight: CGFloat
    private let colorButtons: [UIButton]
    private let colorPickerStackView: UIStackView
    private let selected = UIView()
    
    var selectColorClosure: ((_ color: UIColor) -> Void)?

    
    init(height: CGFloat,
         selectedColor: ((_ color: UIColor) -> Void)? = nil) {
        selectColorClosure = selectedColor
        
        selected.translatesAutoresizingMaskIntoConstraints = false
        selected.layer.cornerRadius = 26
        selected.layer.borderWidth = 3
        selected.layer.borderColor = UIColor.white.cgColor
        selected.widthAnchor.constraint(equalToConstant: 52).isActive = true
        selected.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        intrinsicHeight = height - 48.0
        colorButtons = [UIColor.label,
                        UIColor.systemRed,
                        UIColor.systemOrange,
                        UIColor.systemYellow,
                        UIColor.systemGreen,
                        UIColor.systemBlue]
            .enumerated()
            .map { (offset: Int, color: UIColor) -> UIButton in
                let button = UIButton(type: .system)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.layer.cornerRadius = 20
                button.backgroundColor = color
                button.tag = offset
                button.widthAnchor.constraint(equalToConstant: 40).isActive = true
                button.heightAnchor.constraint(equalToConstant: 40).isActive = true
                return button
        }

        
        colorPickerStackView = UIStackView(arrangedSubviews: colorButtons)
        colorPickerStackView.translatesAutoresizingMaskIntoConstraints = false
        colorPickerStackView.distribution = .equalSpacing
        
        super.init(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        translatesAutoresizingMaskIntoConstraints = false
        
        do {
            configureButtonTargets()
            configureViews()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Button Targets
    
    private func configureButtonTargets() {
        colorButtons.forEach { button in
            button.addTarget(self, action: #selector(selectColorAction), for: .touchUpInside)
        }
    }
    
    override func draw(_ rect: CGRect) {
        selected.center = colorButtons.first?.center ?? .zero
    }
    // MARK: - Configure Views
    
    private func configureViews() {
        contentView.addSubview(colorPickerStackView)
        colorPickerStackView.topAnchor.constraint(equalTo: topAnchor, constant: 32).isActive = true
        colorPickerStackView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        colorPickerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        colorPickerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        
        colorPickerStackView.addSubview(selected)
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

        UIView.animate(withDuration: 0.3) {
            self.selected.center = sender.center
        }
    }
}
