// MyGroupCollectionViewCell.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import UIKit

class MyGroupCollectionViewCell: UICollectionViewCell {
    public private(set) var record: CKRecord?

    private lazy var contactImageView: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.tintColor = .systemOrange
        v.contentMode = .center
        return v
    }()

    private lazy var contactTitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.4
        l.layer.shadowColor = UIColor.black.cgColor
        l.layer.shadowOffset = .zero
        l.layer.shadowRadius = 1
        l.layer.shadowOpacity = 1.0
        l.textAlignment = .center
        l.lineBreakMode = .byTruncatingTail
        return l
    }()

    override init(frame _: CGRect) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
        bootstrap()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(record: CKRecord) {
        self.record = record

        switch record[GroupKey.avatar] as? Data {
        case let .some(data): contactImageView.image = UIImage(data: data)
        case .none: contactImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        }

        if let title = record[GroupKey.name] as? String {
            let userCount = record[GroupKey.userCount] as? Int ?? 1
            let attributedString = NSMutableAttributedString()
            switch userCount {
            case 1 ... 50:
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = UIImage(systemName: "\(userCount).circle.fill",
                                                withConfiguration: UIImage.SymbolConfiguration(scale: .large))?
                    .withTintColor(.label, renderingMode: .alwaysTemplate)
                attributedString.append(NSAttributedString(attachment: imageAttachment))
            default: break
            }
            attributedString.append(NSAttributedString(string: "\(title)"))
            contactTitleLabel.attributedText = attributedString
        }
    }
}

extension MyGroupCollectionViewCell: ViewBootstrappable {
    internal func configureViews() {
        contentView.addSubview(contactImageView)
        contactImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        contactImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        contactImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        contactImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true

        contentView.addSubview(contactTitleLabel)
        contactTitleLabel.heightAnchor.constraint(equalToConstant: 32).isActive = true
        contactTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4).isActive = true
        contactTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        contactTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
}
