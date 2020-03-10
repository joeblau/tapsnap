// MenuCellTableViewCell.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

final class MenuCellTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        imageView?.tintColor = .label
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
