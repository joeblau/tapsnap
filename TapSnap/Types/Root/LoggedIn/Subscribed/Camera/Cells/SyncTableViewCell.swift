// SyncTableViewCell.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

final class SyncTableViewCell: UITableViewCell {
    private lazy var playSwitch: UISwitch = {
        let s = UISwitch()
        s.addTarget(self, action: #selector(toggleAudioSyncAction(_:)), for: .valueChanged)
        s.isOn = Current.musicSyncSubject.value
        return s
    }()

    override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(playbackTime: TimeInterval) {
        imageView?.image = UIImage(systemName: "metronome")
        imageView?.tintColor = .label
        textLabel?.text = L10n.titleMusicSync

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

    @objc func toggleAudioSyncAction(_ sender: UISwitch) {
        Current.musicSyncSubject.send(sender.isOn)
    }
}
