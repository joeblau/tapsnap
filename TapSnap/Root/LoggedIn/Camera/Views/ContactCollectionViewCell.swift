//
//  ContactCollectionViewCell.swift
//  Dolo
//
//  Created by Joe Blau on 2/2/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

final class ContactCollectionViewCell: UICollectionViewCell {
    
    private lazy var contactImageView: UIImageView  = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.6
        l.layer.shadowColor = UIColor.black.cgColor
        l.layer.shadowOffset = .zero
        l.layer.shadowRadius = 1
        l.layer.shadowOpacity = 1.0
        l.layer.masksToBounds = false
        l.clipsToBounds = false
        l.textAlignment = .center
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemBackground
        bootstrap()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(image: UIImage,
                   title: String,
                   groupSize: Int = 0) {
        contactImageView.image = image
        
        let attributedString = NSMutableAttributedString()
        switch groupSize {
        case 1...50:
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "\(groupSize).circle.fill",
                withConfiguration: UIImage.SymbolConfiguration(scale: .small))?.withTintColor(.cyan, renderingMode: .alwaysOriginal)
            
            attributedString.append(NSAttributedString(attachment: imageAttachment))
        default: break
        }
        attributedString.append(NSAttributedString(string: "\(title)"))
        titleLabel.attributedText = attributedString
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contactImageView.image = nil
    }

    // MARK: - Resuse Identifier
    
    static let id = String(describing: ContactCollectionViewCell.self)

}

// MARK: - ViewBootstrappable

extension ContactCollectionViewCell: ViewBootstrappable {
    internal func configureViews() {
        addSubview(contactImageView)
        contactImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contactImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contactImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contactImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        addSubview(titleLabel)
        titleLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2).isActive = true
    }
    
}
