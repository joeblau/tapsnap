//
//  PlaybackView.swift
//  Dolo
//
//  Created by Joe Blau on 2/3/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit
import AVKit

final class PlaybackView: UIView {
    private let backButton = UIButton(type: .system)
    private let groupNameButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let navigationStackView: UIStackView
    private let player: AVPlayer
    private let playerLayer: AVPlayerLayer
    
    init(url: URL, groupName: String) {
        
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        
        do {
            backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
            backButton.floatButton()
        }
        
        do {
            groupNameButton.setTitle(groupName, for: .normal)
            groupNameButton.floatButton()
        }
        
        do {
            nextButton.setImage(UIImage(systemName: "forward.end"), for: .normal)
            nextButton.floatButton()
        }
        
        navigationStackView = UIStackView(arrangedSubviews: [backButton, groupNameButton, nextButton])
        navigationStackView.translatesAutoresizingMaskIntoConstraints = false
        navigationStackView.distribution = .equalSpacing
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.addSublayer(playerLayer)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    // MARK: - Configure Views
    
    private func configureViews() {
        addSubview(navigationStackView)
        navigationStackView.heightAnchor.constraint(equalToConstant: 56).isActive = true
        navigationStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        navigationStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        navigationStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
    }
    
    //
    
    public func play() {
        player.play()
    }
    
}
