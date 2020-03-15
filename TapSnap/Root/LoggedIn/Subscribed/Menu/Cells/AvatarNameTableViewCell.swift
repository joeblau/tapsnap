// AvatarNameTableViewCell.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit
import CloudKit

class AvatarNameTableViewCell: UITableViewCell {
    lazy var avatarView: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .tertiarySystemBackground
        v.contentMode = .scaleAspectFill
        v.imageView?.layer.cornerRadius = 32
        v.layer.cornerRadius = 32
        return v
    }()

    private lazy var nameView: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.preferredFont(forTextStyle: .headline)
        l.textColor = .label
        return l
    }()

    override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        translatesAutoresizingMaskIntoConstraints = false
        selectionStyle = .none
        
        
        guard let userRecord = Current.cloudKitUserSubject.value else { return }
        
        CKContainer.default().fetchUser(with: userRecord.recordID) { [unowned self] (username, avatar) in
            DispatchQueue.main.async {
                self.nameView.text = username
                self.avatarView.setImage(avatar, for: .normal)
            }
        }
        
        bootstrap()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AvatarNameTableViewCell: ViewBootstrappable {
    func configureViews() {
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true

        contentView.addSubview(avatarView)
        avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        avatarView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        avatarView.widthAnchor.constraint(equalToConstant: 64).isActive = true

        contentView.addSubview(nameView)
        nameView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        nameView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        nameView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 8).isActive = true
        nameView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
    }
}
