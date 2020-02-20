//
//  AvatarNameTableViewCell.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/19/20.
//

import UIKit

class AvatarNameTableViewCell: UITableViewCell {
    
    lazy var avatarView: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .tertiarySystemBackground
        v.contentMode = .scaleAspectFill
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        translatesAutoresizingMaskIntoConstraints = false
        guard let nameComponents = Current.cloudKitUserSubject
            .value?
            .nameComponents else { return }
        nameView.text = Current.formatter.personName.string(from: nameComponents)
        bootstrap()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Resuse Identifier

    static let id = String(describing: AvatarNameTableViewCell.self)
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
