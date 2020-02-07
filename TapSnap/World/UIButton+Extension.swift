//
//  UIButton+Extension.swift
//  Dolo
//
//  Created by Joe Blau on 2/3/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

enum SegmentPosition {
    case top
    case middle
    case bottom
}

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
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
    }
    
    func segmentButton(position: SegmentPosition) {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemBackground
        tintColor = .label
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 4
        layer.shadowOpacity = 1.0
        
        switch position {
        case .top:
            layer.cornerRadius = 8
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .bottom:
            layer.cornerRadius = 8
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .middle: break
        }
    }
    
    func setBackgroundColor(color: UIColor, for: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: `for`)
        }
    }
}
