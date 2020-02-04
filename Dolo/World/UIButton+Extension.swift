//
//  UIButton+Extension.swift
//  Dolo
//
//  Created by Joe Blau on 2/3/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

extension UIButton {
    func floatButton() {
        translatesAutoresizingMaskIntoConstraints = false
        tintColor = .label
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 2
        layer.shadowOpacity = 1.0
    }
    
    func keyboardAccessory(alpha: CGFloat = 0.3) {
        translatesAutoresizingMaskIntoConstraints = false
        tintColor = .label
        backgroundColor = UIColor.label.withAlphaComponent(alpha)
        layer.cornerRadius = 8
    }
    
    func notification(diameter: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        titleEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel?.adjustsFontSizeToFitWidth = true
        backgroundColor = .systemRed
        tintColor = .label
        layer.cornerRadius = diameter/2.0
        layer.borderWidth = 3
        layer.borderColor = UIColor.white.cgColor
    }
}
