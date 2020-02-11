// UILabel+Extension.swift
// Copyright (c) 2020 Tapsnap, LLC

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
