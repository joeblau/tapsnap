//
//  UILabel+Extension.swift
//  Dolo
//
//  Created by Joe Blau on 2/4/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

extension UILabel {
    func floatLabel() {
        translatesAutoresizingMaskIntoConstraints = false
        tintColor = .label
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 2
        layer.shadowOpacity = 1.0
    }
}
