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

// data source

class TapSnapPlaybackView: UIView {

    let playbackView: PlaybackView
    let mapView = PlaybackMapView()
    let playbackStack: UIStackView
    
    override init(frame: CGRect) {
        guard let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8") else {
            fatalError("can't get url")
        }
        playbackView = PlaybackView(url: url)
        
        playbackStack = UIStackView(arrangedSubviews: [playbackView, mapView])
        playbackStack.translatesAutoresizingMaskIntoConstraints = false
        playbackStack.axis = .vertical
        playbackStack.distribution = .fillEqually
        
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        backgroundColor = .systemBackground

        do {
            configureViews()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Views
    
    private func configureViews() {
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
        
        addSubview(playbackStack)
        playbackStack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        playbackStack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        playbackStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        playbackStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

}
