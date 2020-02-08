//
//  SyncTableViewCell.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/7/20.
//

import UIKit

final class SyncTableViewCell: UITableViewCell {
    private lazy var playSwitch: UISwitch = {
        let s = UISwitch()
        return s
    }()
    
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
