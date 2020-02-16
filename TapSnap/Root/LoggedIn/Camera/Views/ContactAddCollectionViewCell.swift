//
//  ContactAddCollectionViewCell.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/16/20.
//

import UIKit

class ContactAddCollectionViewCell: UICollectionViewCell {
    
    lazy var addContactView: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "person.badge.plus"))
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFit
        v.tintColor = .label
        return v
    }()
    
    override init(frame _: CGRect) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .tertiarySystemBackground
        bootstrap()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Resuse Identifier

    static let id = String(describing: ContactAddCollectionViewCell.self)
}

extension ContactAddCollectionViewCell: ViewBootstrappable {
    func configureViews() {
        
        addContactView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        addContactView.heightAnchor.constraint(equalToConstant: 32).isActive = true

        contentView.addSubview(addContactView)
        addContactView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        addContactView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
}
