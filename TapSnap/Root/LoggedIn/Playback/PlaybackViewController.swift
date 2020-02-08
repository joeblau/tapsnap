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

final class PlaybackViewController: UIViewController {
    
    private lazy var backButton: UIBarButtonItem = {
        let b = UIBarButtonItem(image: UIImage(systemName: "chevron.down"),
                                style: .plain,
                                target: self,
                                action: #selector(dismissAction))
        b.tintColor = .label
        return b
    }()
    
    private lazy var groupNameButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("Pop That", for: .normal)
        b.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        b.floatButton()
        return b
    }()
    
    private lazy var nextButton: UIBarButtonItem = {
        let b = UIBarButtonItem(image: UIImage(systemName: "forward.end"),
                                style: .plain,
                                target: self,
                                action: #selector(nextAction))
        b.tintColor = .label
        return b
    }()
    
    private lazy var mapView: PlaybackMapView = {
        PlaybackMapView()
    }()
    
    private lazy var playbackView: PlayerView = {
        let v = PlayerView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.playerLayer.videoGravity = .resizeAspectFill
        return v
    }()
    
    // MARK: - Lifecycle
    
    init(url: URL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!) {
        super.init(nibName: nil, bundle: nil)
        playbackView.player = AVPlayer(url: url)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        bootstrap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playbackView.player?.play()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        playbackView.player?.pause()
        playbackView.player = nil
    }
    
    // MARK: - Actions
    
    @objc func dismissAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func groupSettingsAction() {}
    
    @objc func nextAction() {
        guard self == navigationController?.viewControllers.first else {
            navigationController?.popViewController(animated: true)
            return
        }
        dismiss(animated: true, completion: nil)
    }
}


extension PlaybackViewController: ViewBootstrappable {
    func configureViews() {
        navigationItem.titleView = groupNameButton
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = nextButton
        
        view.addSubview(playbackView)
        playbackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        playbackView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height/2).isActive = true
        playbackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playbackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true


        view.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: playbackView.bottomAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    internal func configureButtonTargets() {
        groupNameButton.addTarget(self, action: #selector(groupSettingsAction), for: .touchUpInside)
    }
}
