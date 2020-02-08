//
//  TapSnapPlaybackView.swift
//  Dolo
//
//  Created by Joe Blau on 2/5/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit
import AVKit
import MapKit

final class TapSnapPlaybackView: UIView {

    private lazy var playbackView: PlaybackView = {
        guard let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8") else {
             fatalError("can't get url")
         }
        return PlaybackView(url: url)
    }()
    
    private lazy var mapView: PlaybackMapView = {
        PlaybackMapView()
    }()
    private lazy var playbackStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [playbackView, mapView])
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.distribution = .fillEqually
        return s
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        bootstrap()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ViewBootstrappable

extension TapSnapPlaybackView: ViewBootstrappable {
    internal func configureViews() {
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
        
        addSubview(playbackStack)
        playbackStack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        playbackStack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        playbackStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        playbackStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
