//
//  MessageViewController.swift
//  Dolo
//
//  Created by Joe Blau on 2/3/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit
import Combine
import MapKit
import CoreLocation
import Contacts

final class PlaybackViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()
    
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
    
    private lazy var spacer: UIBarButtonItem = { UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)  }()
    
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
    
    private lazy var playerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var mapCamera: MKMapCamera = { MKMapCamera() }()

    
    private lazy var mapViewContainer: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isUserInteractionEnabled = true
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self

        title = "Pop That"
        view.backgroundColor = .systemBackground
        view.floatView()
        if let playerPath = Bundle.main.path(forResource: "ts1", ofType:"mov") {
            looper = PlayerLooper(videoURL: URL(fileURLWithPath: playerPath), loopCount: 0)
        }
        toolbarItems = [saveButton, spacer, heartButton]
        populateMapAndMapOverlay()
        bootstrap()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        looper?.start(in: playerView.layer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Save imag eof map

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        looper?.stop()
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
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
    
    @objc func saveTapAction() {}
    
    @objc func heartTapAction() {
        isHearted.toggle()
    }
    
    private func populateMapAndMapOverlay() {
        
        let myLocation: CLLocation = CLLocation(latitude: 37.759580, longitude: -122.391850)
        let theirLocation: CLLocation = CLLocation(latitude: 33.996890, longitude: -84.428710)
        let theirAddresss: CNPostalAddress = Current.fakeContact
        let theirDate: Date = Date(timeIntervalSince1970: 1579947732)
        
        let theirAnnotation : MKPointAnnotation = {
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
                                 theirAddresss: theirAddresss,
                                 theirDate: theirDate)
    }
}


extension PlaybackViewController: ViewBootstrappable {
    func configureViews() {
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = nextButton
        
        view.addSubview(playerView)
        playerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        playerView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height/2).isActive = true
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
            snapshot.start { (snapshot, error) in
                self.mapViewContainer.image = snapshot?.image
            }
        }
    }
}
