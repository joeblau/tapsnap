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
}
