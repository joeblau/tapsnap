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
    private let url: URL
    private lazy var player: AVPlayer = {
        return AVPlayer(url: url)
    }()
    private lazy var playerLayer: AVPlayerLayer = {
        let pl = AVPlayerLayer(player: player)
        pl.videoGravity = .resizeAspectFill
        return pl
    }()
    
    init(url: URL) {
        self.url = url
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.addSublayer(playerLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    deinit { removeFromSuperview() }
    
    
    public func play() {
        player.play()
    }
    
}
