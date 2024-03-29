// PlaybackViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import AVFoundation
import CloudKit
import Combine
import Contacts
import CoreLocation
import MapKit
import UIKit

final class PlaybackViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()
    private let mediaCapture: MediaCapture
    private let playbackMetadata: PlaybackMetadata?
    var senderImage: UIImage?

    private lazy var backButton: UIBarButtonItem = {
        let b = UIBarButtonItem(image: UIImage(systemName: "chevron.down"),
                                style: .plain,
                                target: self,
                                action: #selector(dismissAction))
        b.tintColor = .label
        return b
    }()

    private lazy var nextButton: UIBarButtonItem = {
        let bbi = UIBarButtonItem(image: UIImage(systemName: "forward.end"),
                                  style: .plain,
                                  target: self,
                                  action: #selector(nextAction))
        bbi.tintColor = .label
        return bbi
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

    private lazy var currentSongView = CurrentSongView()

    private lazy var currentSongButton: UIBarButtonItem = {
        let bbi = UIBarButtonItem(customView: currentSongView)
        return bbi
    }()

    private lazy var spacer: UIBarButtonItem = { UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) }()

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

    private lazy var playerView: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFill
        return v
    }()

    private lazy var mapCamera: MKMapCamera = { MKMapCamera() }()

    private lazy var mapViewContainer: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isUserInteractionEnabled = true
        v.contentMode = .scaleAspectFill
        return v
    }()

    private lazy var mapView: MKMapView = {
        let v = MKMapView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isZoomEnabled = false
        v.isScrollEnabled = false
        v.isRotateEnabled = false
        v.isPitchEnabled = false
        v.showsCompass = false
        v.showsScale = false
        v.showsBuildings = true
        v.showsUserLocation = true
        v.delegate = self
        return v
    }()

    private lazy var mapOverlayView: MapViewOverlay = { MapViewOverlay() }()

    var looper: PlayerLooper?

    // MARK: - Lifecycle

    init(messageURL: URL) {
        guard let data = try? Data(contentsOf: messageURL) else { fatalError("invalid data") }

        switch UIImage(data: data) {
        case .some:
            mediaCapture = MediaCapture.photo(messageURL)
            playbackMetadata = data.playbackMetadata
        case .none:
            mediaCapture = MediaCapture.movie(messageURL)
            playbackMetadata = AVAsset(url: messageURL).metadata.playbackMetadta
        }

        super.init(nibName: nil, bundle: nil)

        if let coverArt = playbackMetadata?.coverArt,
            let artist = playbackMetadata?.artist,
            let title = playbackMetadata?.title,
            let songID = playbackMetadata?.songId {
            currentSongView.configure(image: coverArt,
                                      artist: artist,
                                      title: title,
                                      songID: songID)
        }
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationController?.navigationBar.layer.shadowOffset = .zero
        navigationController?.navigationBar.layer.shadowRadius = 3
        navigationController?.navigationBar.layer.shadowOpacity = 1

        title = playbackMetadata?.author
        view.backgroundColor = .systemBackground
        view.floatView()

        switch mediaCapture {
        case let .photo(url):
            guard let data = try? Data(contentsOf: url) else { return }
            playerView.image = UIImage(data: data)
        case let .movie(url):
            looper = PlayerLooper(videoURL: url, loopCount: 0)
        }
        toolbarItems = [saveButton, spacer, currentSongButton, spacer, heartButton]
        populateMapAndMapOverlay()
        bootstrap()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch mediaCapture {
        case .photo: break
        case .movie: looper?.start(in: playerView.layer)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        switch mediaCapture {
        case let .photo(url):
            try? FileManager.default.removeItem(at: url)
        case let .movie(url):
            try? FileManager.default.removeItem(at: url)
            looper?.stop()
        }

        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }

    // MARK: - Actions

    @objc func dismissAction() {
        Current.presentViewContollersSubject.send(.camera)
    }

    @objc func groupSettingsAction() {}

    @objc func nextAction() {
        guard self == navigationController?.viewControllers.first else {
            navigationController?.popViewController(animated: true)
            return
        }
        Current.presentViewContollersSubject.send(.camera)
    }

    @objc func saveTapAction() {}

    @objc func heartTapAction() {
        isHearted.toggle()
    }

    private func populateMapAndMapOverlay() {
        senderImage = playbackMetadata?.thumbnail
        title = playbackMetadata?.group

        if let theirCoordinate = playbackMetadata?.location?.coordinate {
            let annotation = MKPointAnnotation()
            let coordiante = theirCoordinate
            annotation.coordinate = coordiante
            annotation.title = playbackMetadata?.author
            mapView.addAnnotation(annotation)
        }

        mapOverlayView.configure(playbackMetadata: playbackMetadata)
    }
}

extension PlaybackViewController: ViewBootstrappable {
    func configureViews() {
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = nextButton

        view.addSubview(playerView)
        playerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        playerView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.6).isActive = true
        playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        view.addSubview(mapViewContainer)
        mapViewContainer.topAnchor.constraint(equalTo: playerView.bottomAnchor).isActive = true
        mapViewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapViewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        mapViewContainer.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: mapViewContainer.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: mapViewContainer.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: mapViewContainer.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: mapViewContainer.trailingAnchor).isActive = true

        mapViewContainer.addSubview(mapOverlayView)
        mapOverlayView.topAnchor.constraint(equalTo: mapViewContainer.topAnchor).isActive = true
        mapOverlayView.bottomAnchor.constraint(equalTo: mapViewContainer.bottomAnchor).isActive = true
        mapOverlayView.leadingAnchor.constraint(equalTo: mapViewContainer.leadingAnchor).isActive = true
        mapOverlayView.trailingAnchor.constraint(equalTo: mapViewContainer.trailingAnchor).isActive = true
    }

    internal func configureStreams() {
        Current.mapDimensionSubject.sink { dimension in

            self.mapCamera.centerCoordinate = self.mapView
                .annotations
                .first(where: { !($0 is MKUserLocation) })?
                .coordinate ?? CLLocation().coordinate

            switch dimension {
            case .two:
                self.mapView.mapType = .mutedStandard

                self.mapCamera.pitch = 0
                self.mapCamera.altitude = 500
                self.mapCamera.heading = 0

            case .three:
                self.mapView.mapType = .satelliteFlyover

                self.mapCamera.pitch = 45
                self.mapCamera.altitude = 500
                self.mapCamera.heading = 45
            }

            self.updateMapSnapshot()
        }.store(in: &cancellables)

        Current.mapAnnotationsSubject.sink { annotationsGroup in
            switch annotationsGroup {
            case .them:
                self.mapView.mapType = .mutedStandard

                self.mapCamera.pitch = 0
                self.mapCamera.altitude = 500
                self.mapCamera.heading = 0

                self.updateMapSnapshot()
            case .all:
                self.mapView.showAnnotations(self.mapView.annotations, animated: false)
            }
        }.store(in: &cancellables)
    }

    private func updateMapSnapshot() {
        UIView.animate(withDuration: 0.5, animations: {
            self.mapView.camera = self.mapCamera
        }) { completed in
            guard completed else { return }

            let options = MKMapSnapshotter.Options()
            options.camera = self.mapCamera
            options.scale = UIScreen.main.scale
            options.size = self.mapView.frame.size

            let snapshot = MKMapSnapshotter(options: options)
            snapshot.start { snapshot, _ in
                self.mapViewContainer.image = snapshot?.image
            }
        }
    }
}
