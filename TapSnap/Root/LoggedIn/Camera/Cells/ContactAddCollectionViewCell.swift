// ContactAddCollectionViewCell.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

class ContactAddCollectionViewCell: UICollectionViewCell {
    private lazy var addContactView: UIImageView = {
        let i = UIImage(systemName: "person.crop.circle.badge.plus",
                        withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        let v = UIImageView(image: i)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.tintColor = .label
        v.contentMode = .center
        return v
    }()

    // MARK: - Lifecycle

    override init(frame _: CGRect) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemBackground
        bootstrap()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Resuse Identifier

    static let id = String(describing: ContactAddCollectionViewCell.self)
}

// MARK: - ViewBootstrappable

extension ContactAddCollectionViewCell: ViewBootstrappable {
    func configureViews() {
        contentView.addSubview(addContactView)
        addContactView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        addContactView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        addContactView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        addContactView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
}
