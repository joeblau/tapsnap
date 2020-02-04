//
//  PlaybackMapView.swift
//  Dolo
//
//  Created by Joe Blau on 2/3/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit
import MapKit
import Combine
import CoreLocation
import Contacts

class PlaybackMapView: MKMapView {
    
    let timeDistanceLocation = UILabel()
    private var cancellables = Set<AnyCancellable>()
    let kButtonSize: CGFloat = 48
    let kButtonPadding: CGFloat = 8
    
    let toggle3DButton = UIButton(type: .system)
    let toggleAnnotationsButton = UIButton(type: .system)
    let mapActionsStack: UIStackView
    
    private let mapCamera = MKMapCamera()
    private let theirAnnotation = MKPointAnnotation()
    private let myAnnotation = MKPointAnnotation()

    init(myLocation: CLLocation = CLLocation(latitude: 37.759580, longitude: -122.391850),
         theirLocation: CLLocation = CLLocation(latitude: 33.996890, longitude: -84.428710),
         theirAddresss: CNPostalAddress? = nil,
         theirDate: Date = Date(timeIntervalSince1970: 1579947732)) {
        
        let pa = CNMutablePostalAddress()
        pa.street = "1884 Wood Acres Lane"
        pa.city = "Marieta"
        pa.state = "Georga"
        pa.postalCode = "30062"
        pa.country = "United States"

        timeDistanceLocation.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        timeDistanceLocation.adjustsFontSizeToFitWidth = true
        timeDistanceLocation.minimumScaleFactor = 0.6
        timeDistanceLocation.numberOfLines = 0
        timeDistanceLocation.floatLabel()
        
        toggle3DButton.setImage(UIImage(systemName: "view.3d"), for: .normal)
        toggle3DButton.accessibilityIdentifier = "3d"
        toggle3DButton.segmentButton(position: .top)
        
        toggleAnnotationsButton.setImage(UIImage(systemName: "person.2"), for: .normal)
        toggleAnnotationsButton.accessibilityIdentifier = "all"
        toggleAnnotationsButton.segmentButton(position: .bottom)

        mapActionsStack = UIStackView(arrangedSubviews: [toggle3DButton, toggleAnnotationsButton])
        mapActionsStack.translatesAutoresizingMaskIntoConstraints = false
        mapActionsStack.axis = .vertical
        mapActionsStack.spacing = UIStackView.spacingUseSystem
        
        super.init(frame: .zero)
        delegate = self
        isZoomEnabled = false
        isScrollEnabled = false
        isRotateEnabled = false
        isPitchEnabled = false
        showsCompass = false
        showsScale = false
        showsBuildings = true
        translatesAutoresizingMaskIntoConstraints = false
        register(PersonAnnotationView.self, forAnnotationViewWithReuseIdentifier: PersonAnnotationView.id)
        
        do {
            myAnnotation.coordinate = myLocation.coordinate
            myAnnotation.title = "You"
            addAnnotation(myAnnotation)
            
            theirAnnotation.coordinate = theirLocation.coordinate
            theirAnnotation.title = "Shane"
            addAnnotation(theirAnnotation)
        }
        
        do {
            configureButtonTargets()
            configureViews()
            configureStreams()
        }
        
        var coordinates = [myLocation.coordinate, theirAnnotation.coordinate]
        let geodesicPolyline = MKGeodesicPolyline(coordinates: &coordinates, count: coordinates.count)
        addOverlay(geodesicPolyline)
                
        let distance = myLocation.distance(from: theirLocation)
        timeDistanceLocation.attributedText = formatMetadata(address: pa,
                                                             date: theirDate,
                                                             distance: distance)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Button Targets
    
    private func configureButtonTargets() {
        toggle3DButton.addTarget(self, action: #selector(toggleMapPreviewModeAction), for: .touchUpInside)
        toggleAnnotationsButton.addTarget(self, action: #selector(toggleAnnotationsGroupAction), for: .touchUpInside)
    }
    
    // MARK: - Configure Views
    
    private func configureViews() {
        toggle3DButton.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        toggle3DButton.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        
        toggleAnnotationsButton.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        toggleAnnotationsButton.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
    
        
        addSubview(mapActionsStack)
        mapActionsStack.heightAnchor.constraint(greaterThanOrEqualToConstant: kButtonSize).isActive = true
        mapActionsStack.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        mapActionsStack.topAnchor.constraint(equalTo: topAnchor, constant: kButtonPadding).isActive = true
        mapActionsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -kButtonPadding).isActive = true
        
        addSubview(timeDistanceLocation)
        timeDistanceLocation.topAnchor.constraint(equalTo: topAnchor, constant: kButtonPadding).isActive = true
        timeDistanceLocation.heightAnchor.constraint(greaterThanOrEqualToConstant: kButtonSize).isActive = true
        timeDistanceLocation.leadingAnchor.constraint(equalTo: leadingAnchor, constant: kButtonPadding).isActive = true
        timeDistanceLocation.trailingAnchor.constraint(equalTo: mapActionsStack.leadingAnchor, constant: -kButtonPadding).isActive = true
        

    }
    
    // MARK: - Configure Streams
    
    private func configureStreams() {
        Current.mapDimensionSubject.sink(receiveValue: { dimension in
            self.mapCamera.centerCoordinate = self.theirAnnotation.coordinate

            switch dimension {
            case .two:
                self.toggle3DButton.setImage(UIImage(systemName: "view.3d"), for: .normal)
                self.toggle3DButton.accessibilityIdentifier = "3d"

                self.mapType = .mutedStandard

                self.mapCamera.pitch = 0
                self.mapCamera.altitude = 500
                self.mapCamera.heading = 0
                
            case .three:
                self.toggle3DButton.setImage(UIImage(systemName: "view.2d"), for: .normal)
                self.toggle3DButton.accessibilityIdentifier = "2d"

                self.mapType = .satelliteFlyover
        
                self.mapCamera.pitch = 45
                self.mapCamera.altitude = 500
                self.mapCamera.heading = 45
            }
            UIView.animate(withDuration: 0.5) {
                self.camera = self.mapCamera
            }
        })
        .store(in: &cancellables)
        
        
        Current.mapAnnotationsSubject.sink(receiveValue: { annotationsGroup in

            switch annotationsGroup {
            case .them:
                self.toggle3DButton.isEnabled = true
                self.toggleAnnotationsButton.setImage(UIImage(systemName: "person.2"), for: .normal)
                self.toggleAnnotationsButton.accessibilityIdentifier = "all"
                
                self.mapType = .mutedStandard
                
                self.mapCamera.pitch = 0
                self.mapCamera.altitude = 500
                self.mapCamera.heading = 0
                
                UIView.animate(withDuration: 0.5) {
                     self.camera = self.mapCamera
                 }
            case .all:
                self.toggle3DButton.isEnabled = false
                self.toggleAnnotationsButton.setImage(UIImage(systemName: "person"), for: .normal)
                self.toggleAnnotationsButton.accessibilityIdentifier = "them"
                
                self.showAnnotations(self.annotations, animated: true)
            }
        })
        .store(in: &cancellables)
        
    }
    
    private func formatMetadata(address: CNPostalAddress?,
                                date: Date,
                                distance: CLLocationDistance) -> NSAttributedString {
        let attributedMetadataString = NSMutableAttributedString()
        
        if let formattedAddress = address?.streetCity {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "mappin.and.ellipse",
                                            withConfiguration: UIImage.SymbolConfiguration(scale: .small))?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
            
            attributedMetadataString.append(NSAttributedString(attachment: imageAttachment))
            attributedMetadataString.append(NSAttributedString(string: " \(formattedAddress)\n"))
        }

        do { // distance
             let formattedDistance = Current.formatter.distance.string(fromDistance: distance)
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "map",
                                            withConfiguration: UIImage.SymbolConfiguration(scale: .small))?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
            
            attributedMetadataString.append(NSAttributedString(attachment: imageAttachment))
            attributedMetadataString.append(NSAttributedString(string: " \(formattedDistance) away\n"))
        }
        
        do { // Time Ago
            let formattedTimeAgo = Current.formatter.timeAgo.localizedString(for: date, relativeTo: Date())
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "clock",
                                            withConfiguration: UIImage.SymbolConfiguration(scale: .small))?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
            
            attributedMetadataString.append(NSAttributedString(attachment: imageAttachment))
            attributedMetadataString.append(NSAttributedString(string: " \(formattedTimeAgo)\n"))
        }
        
        return attributedMetadataString
        
    }
    
    // MARK: - Button Targets
    
    @objc func toggleMapPreviewModeAction(sender: UIButton) {
        switch sender.accessibilityIdentifier {
        case let .some(identifier) where identifier == "2d":
            Current.mapDimensionSubject.send(.two)
        case let .some(identifier) where identifier == "3d":
            Current.mapDimensionSubject.send(.three)
        default: break
        }
    }
    
    @objc func toggleAnnotationsGroupAction(sender: UIButton) {
        switch sender.accessibilityIdentifier {
        case let .some(identifier) where identifier == "them":
            Current.mapAnnotationsSubject.send(.them)
        case let .some(identifier) where identifier == "all":
            Current.mapAnnotationsSubject.send(.all)
        default: break
        }
    }
    
}

extension PlaybackMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }
        
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.lineWidth = 6.0
        renderer.alpha = 0.5
        renderer.strokeColor = .systemYellow
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MKPointAnnotation,
            let view = dequeueReusableAnnotationView(withIdentifier: PersonAnnotationView.id,
                                                     for: annotation) as? PersonAnnotationView else {
                                                        return nil
        }
        
        let idx = Int.random(in: 0 ... 10)
        let url = URL(string: "https://i.pravatar.cc/150?img=\(idx)")!
        URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data)! }
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                //                print(completion)
            }) { image in
                view.configure(image: image)
        }
        .store(in: &self.cancellables)
        
        return view
    }
}
