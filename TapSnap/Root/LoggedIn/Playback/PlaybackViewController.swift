// PlaybackViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import Combine
import Contacts
import CoreLocation
import MapKit
import UIKit

final class PlaybackViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()
    private let mediaCapture: MediaCapture

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
        return v
    }()

    private lazy var mapCamera: MKMapCamera = { MKMapCamera() }()

    private lazy var mapViewContainer: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isUserInteractionEnabled = true
        v.contentMode = .scaleAspectFit
        return v
    }()

    private lazy var mapView: MKMapView = {
        let v = Current.mapView
        v.register(PersonAnnotationView.self, forAnnotationViewWithReuseIdentifier: PersonAnnotationView.id)
        v.delegate = self
        return v
    }()

    private lazy var mapOverlayView: MapViewOverlay = { MapViewOverlay() }()

    private var annotations = [MKPointAnnotation]()
    var looper: PlayerLooper?

    // MARK: - Lifecycle

    init(messageURL: URL) {
        if let data = try? Data(contentsOf: messageURL), let _ = UIImage(data: data) {
            self.mediaCapture = MediaCapture.photo(messageURL)
        } else {
            self.mediaCapture = MediaCapture.movie(messageURL)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pop That"
        view.backgroundColor = .systemBackground
        view.floatView()
        
        switch mediaCapture {
        case let .photo(url):
            guard let data = try? Data(contentsOf: url) else { return }
            playerView.image = UIImage(data: data)
        case let .movie(url):
            looper = PlayerLooper(videoURL: url, loopCount: 0)
        }
        toolbarItems = [saveButton, spacer, heartButton]
        populateMapAndMapOverlay()
        bootstrap()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch mediaCapture {
        case .photo(_): break
        case .movie(_): looper?.start(in: playerView.layer)
        }
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
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
        let myLocation: CLLocation = CLLocation(latitude: 37.759580, longitude: -122.391850)
        let theirLocation: CLLocation = CLLocation(latitude: 33.996890, longitude: -84.428710)
//        let theirAddresss: CNPostalAddress
        let theirDate: Date = Date(timeIntervalSince1970: 1_579_947_732)

        let theirAnnotation: MKPointAnnotation = {
            let pa = MKPointAnnotation()
            pa.coordinate = theirLocation.coordinate
            pa.title = "Shane"
            mapView.addAnnotation(pa)
            return pa
        }()

        annotations.append(theirAnnotation)
        let myAnnotation: MKPointAnnotation = {
            let pa = MKPointAnnotation()
            pa.coordinate = myLocation.coordinate
            pa.title = "You"
            mapView.addAnnotation(pa)
            return pa
        }()
        annotations.append(myAnnotation)

        var coordinates = [myAnnotation.coordinate, theirAnnotation.coordinate]
        let geodesicPolyline = MKGeodesicPolyline(coordinates: &coordinates, count: coordinates.count)
        mapView.addOverlay(geodesicPolyline)

        mapOverlayView.configure(myLocation: myLocation,
                                 theirLocation: theirLocation,
//                                 theirAddresss: theirAddresss,
                                 theirDate: theirDate)
    }
}

extension PlaybackViewController: ViewBootstrappable {
    func configureViews() {
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = nextButton

        view.addSubview(playerView)
        playerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        playerView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 2).isActive = true
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
        Current.mapDimensionSubject.sink(receiveValue: { dimension in
            self.mapCamera.centerCoordinate = self.annotations.last?.coordinate ?? CLLocation().coordinate

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
        })
            .store(in: &cancellables)

        Current.mapAnnotationsSubject.sink(receiveValue: { annotationsGroup in
            switch annotationsGroup {
            case .them:
                self.mapView.mapType = .mutedStandard

                self.mapCamera.pitch = 0
                self.mapCamera.altitude = 500
                self.mapCamera.heading = 0

                self.updateMapSnapshot()
            case .all:
                self.mapView.showAnnotations(self.annotations, animated: false)
            }
        })
            .store(in: &cancellables)
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
