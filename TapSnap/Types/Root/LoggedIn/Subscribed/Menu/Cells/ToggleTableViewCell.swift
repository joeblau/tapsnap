// ToggleTableViewCell.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

class ToggleTableViewCell: UITableViewCell {
    override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        imageView?.tintColor = .label
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(menuItem: MenuItem, enabled: Bool = false) {
        imageView?.image = UIImage(systemName: menuItem.systemName)
        imageView?.tintColor = .label
        textLabel?.text = menuItem.titleText
        detailTextLabel?.text = menuItem.subtitleText
        accessoryType = enabled ? .checkmark : .none
    }
}
