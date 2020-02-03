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
    override init(frame: CGRect) {
        contactImageView.translatesAutoresizingMaskIntoConstraints = false
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemBackground
        
        recordLongPress.addTarget(self, action: #selector(startRecordingAction))
        recordLongPress.minimumPressDuration = 0.1
        addGestureRecognizer(recordLongPress)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    static let id = String(describing: ContactCollectionViewCell.self)
    
    // MARK: - Configure Views
    private func configureViews() {
        addSubview(contactImageView)
        contactImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contactImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contactImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contactImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    func configure(image: UIImage) {
        contactImageView.image = image
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
}
