//
//  MessageViewController.swift
//  Dolo
//
//  Created by Joe Blau on 2/3/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit
import AVKit
import Combine


final class PlaybackViewController: UIViewController {

//    var cancellables = Set<AnyCancellable>()
    
    private lazy var backButton: UIBarButtonItem = {
        let b = UIBarButtonItem(image: UIImage(systemName: "chevron.down"),
                                style: .plain,
                                target: self,
                                action: #selector(dismissAction))
        b.tintColor = .label
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
    
    private lazy var saveButton: UIBarButtonItem = {
        let bbi = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(saveTapAction))
        bbi.tintColor = .label
        return bbi
    }()
    
    private lazy var heartButton: UIBarButtonItem = {
        let bbi = UIBarButtonItem(image: UIImage(systemName: "heart"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(heartTapAction))
        bbi.tintColor = .label
        return bbi
    }()
    
    var isHearted: Bool = false {
        didSet {
            switch isHearted {
            case true:
                heartButton.image = UIImage(systemName: "heart.fill")
                heartButton.tintColor = .systemPink
            case false:
                heartButton.image = UIImage(systemName: "heart")
                heartButton.tintColor = .label
            }
        }
    }
    
    var cancellableMap: AnyCancellable?
    
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
        title = "Pop That"
        view.backgroundColor = .systemBackground
        
        do {
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            toolbarItems = [saveButton, spacer, heartButton]
        }
        bootstrap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playbackView.player?.play()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cancellableMap?.cancel()
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
    
    @objc func saveTapAction() {

    }
    
    @objc func heartTapAction() {
        isHearted.toggle()
    }
}


extension PlaybackViewController: ViewBootstrappable {
    func configureViews() {
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

    internal func configureStreams() {
//        Current.mapDimensionSubject.sink(receiveValue: { dimension in
//            self.mapCamera.centerCoordinate = self.theirccAnnotation.coordinate
//
//            switch dimension {
//            case .two:
//                self.toggle3DButton.setImage(UIImage(systemName: "view.3d"), for: .normal)
//                self.toggle3DButton.accessibilityIdentifier = "3d"
//
//                self.mapType = .mutedStandard
//
//                self.mapCamera.pitch = 0
//                self.mapCamera.altitude = 500
//                self.mapCamera.heading = 0
//
//            case .three:
//                self.toggle3DButton.setImage(UIImage(systemName: "view.2d"), for: .normal)
//                self.toggle3DButton.accessibilityIdentifier = "2d"
//
//                self.mapType = .satelliteFlyover
//
//                self.mapCamera.pitch = 45
//                self.mapCamera.altitude = 500
//                self.mapCamera.heading = 45
//            }
//            UIView.animate(withDuration: 0.5) {
//                self.camera = self.mapCamera
//            }
//        })
//            .store(in: &cancellables)
//
//
//        Current.mapAnnotationsSubject.sink(receiveValue: { annotationsGroup in

//            switch annotationsGroup {
//            case .them:
//                self.toggle3DButton.isEnabled = true
//                self.toggleAnnotationsButton.setImage(UIImage(systemName: "person.2"), for: .normal)
//                self.toggleAnnotationsButton.accessibilityIdentifier = "all"
//
//                self.mapType = .mutedStandard
//
//                self.mapCamera.pitch = 0
//                self.mapCamera.altitude = 500
//                self.mapCamera.heading = 0
//
//                UIView.animate(withDuration: 0.5) {
//                     self.camera = self.mapCamera
//                 }
//            case .all:
//                self.toggle3DButton.isEnabled = false
//                self.toggleAnnotationsButton.setImage(UIImage(systemName: "person"), for: .normal)
//                self.toggleAnnotationsButton.accessibilityIdentifier = "them"
//
//                self.showAnnotations(self.annotations, animated: true)
//            }
//        })
//        .store(in: &cancellables)
    }
}
