// SearchContactTableViewCell.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

final class SearchContactTableViewCell: UITableViewCell {
    // MARK: - Lifecycle

    override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        imageView?.image = UIImage(systemName: "person.crop.circle.fill")
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    public func configure(image: UIImage,
                          friendName: String) {
        imageView?.image = image
        imageView?.contentMode = .scaleAspectFit
        textLabel?.text = friendName
    }

}
