//
//  MessageViewController.swift
//  Dolo
//
//  Created by Joe Blau on 2/3/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit
import AVKit
import MapKit

class PlaybackViewController: UIViewController {

    let playbackView: PlaybackView
    let mapView = PlaybackMapView()
    
    let playbackStack: UIStackView
    
    init() {
        guard let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8") else {
            fatalError("can't get url")
        }
        playbackView = PlaybackView(url: url,
        groupName: "us")
        
        playbackStack = UIStackView(arrangedSubviews: [playbackView, mapView])
        playbackStack.translatesAutoresizingMaskIntoConstraints = false
        playbackStack.axis = .vertical
        playbackStack.distribution = .fillEqually
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        view.backgroundColor = .systemBackground
        
        do {
            configureViews()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Views
    
    private func configureViews() {
        view.addSubview(playbackStack)
        playbackStack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        playbackStack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        playbackStack.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playbackStack.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playbackView.play()
    }
}
