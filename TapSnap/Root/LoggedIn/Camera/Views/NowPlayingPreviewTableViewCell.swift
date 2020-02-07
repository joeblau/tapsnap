//
//  NowPlayingPreviewTableViewCell.swift
//  Dolo
//
//  Created by Joe Blau on 2/5/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

class SyncTableViewCell: UITableViewCell {
        private let playSwitch = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(playbackTime: TimeInterval) {
        imageView?.image = UIImage(systemName: "metronome")
        imageView?.tintColor = .label
        textLabel?.text = "Music Sync"
        
        do {
            let attributedMetadataString = NSMutableAttributedString()

            if let formatPlayback = Current.formatter.progress.string(from: playbackTime) {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "play.fill",
                                            withConfiguration: UIImage.SymbolConfiguration(scale: .small))?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
            
            attributedMetadataString.append(NSAttributedString(attachment: imageAttachment))
            
            attributedMetadataString.append(NSAttributedString(string: " \(formatPlayback)"))
            detailTextLabel?.attributedText = attributedMetadataString
            }
        }
                
        accessoryView = playSwitch
    }
    
    static let id = String(describing: SyncTableViewCell.self)
}

class NowPlayingPreviewTableViewCell: UITableViewCell {

    let artworkImageView = UIImageView()
    let titleLabel = UILabel()
    let artistLabel = UILabel()
    
    let contentStackView: UIStackView
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        do {
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.numberOfLines = 0
            artistLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        }
        
        do {
            artistLabel.translatesAutoresizingMaskIntoConstraints = false
            artistLabel.numberOfLines = 0
            artistLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        }
        
        do {
            artworkImageView.translatesAutoresizingMaskIntoConstraints = false
            artworkImageView.layer.masksToBounds = true
            artworkImageView.layer.cornerRadius = 8
            artworkImageView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        contentStackView = UIStackView(arrangedSubviews: [titleLabel, artistLabel, UIView()])
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.distribution = .fill
        
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        do {
            configureViews()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    func configure(image: UIImage?,
                   title: String?,
                   artist: String?) {
        artworkImageView.image = image
        titleLabel.text = title
        artistLabel.text = artist
    }
    
    // MARK: - Configure Views
    
    private func configureViews() {
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 132).isActive = true
        
        contentView.addSubview(artworkImageView)
        artworkImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        artworkImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        artworkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        artworkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        artworkImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16).isActive = true

        
        contentView.addSubview(contentStackView)
        contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        contentStackView.leadingAnchor.constraint(equalTo: artworkImageView.trailingAnchor, constant: 16).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
    }

    static let id = String(describing: NowPlayingPreviewTableViewCell.self)
}
