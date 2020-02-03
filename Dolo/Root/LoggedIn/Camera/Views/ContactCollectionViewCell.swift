//
//  ContactCollectionViewCell.swift
//  Dolo
//
//  Created by Joe Blau on 2/2/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

class ContactCollectionViewCell: UICollectionViewCell {
    
    let recordLongPress = UILongPressGestureRecognizer()
    let contactImageView = UIImageView()
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        contactImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemBackground
        
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.6
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = .zero
        titleLabel.layer.shadowRadius = 1
        titleLabel.layer.shadowOpacity = 1.0
        titleLabel.layer.masksToBounds = false
        titleLabel.clipsToBounds = false
        titleLabel.textAlignment = .center
        
        configureViews()
        configureGestureRecoginzers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Views
    
    private func configureViews() {
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
    
    private func configureGestureRecoginzers() {
        recordLongPress.addTarget(self, action: #selector(startRecordingAction))
        recordLongPress.minimumPressDuration = 0.1
        addGestureRecognizer(recordLongPress)
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
    
    // MARK: - Actions
    
    @objc func startRecordingAction(recoginzer: UILongPressGestureRecognizer) {
        switch recoginzer.state {
        case .began:
            Current.recordingSubject.value = .start
        case .cancelled, .ended:
            Current.recordingSubject.value = .stop
        default: break
        }
    }

    // MARK: - Resuse Identifier
    
    static let id = String(describing: ContactCollectionViewCell.self)

}
