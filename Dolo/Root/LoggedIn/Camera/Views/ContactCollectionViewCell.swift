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
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemBackground
        
        recordLongPress.addTarget(self, action: #selector(startRecordingAction))
        recordLongPress.minimumPressDuration = 0.1
        addGestureRecognizer(recordLongPress)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    static let id = String(describing: ContactCollectionViewCell.self)
    
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
