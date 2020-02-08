//
//  PlaybackMapView.swift
//  Dolo
//
//  Created by Joe Blau on 2/3/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Contacts

final class PlaybackMapView: MKMapView {
    private let myLocation: CLLocation
    private let theirLocation: CLLocation
    let kButtonSize: CGFloat = 48
    let kButtonPadding: CGFloat = 8
    
    private lazy var timeDistanceLocation: UILabel = {
       let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.6
        l.numberOfLines = 0
        l.floatLabel()
        return l
    }()
    
    private lazy var toggle3DButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "view.3d"), for: .normal)
         b.accessibilityIdentifier = "3d"
         b.segmentButton(position: .top)
        return b
    }()
    
    private lazy var toggleAnnotationsButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "person.2"), for: .normal)
        b.accessibilityIdentifier = "all"
        b.segmentButton(position: .bottom)
        return b
    }()
    
    private lazy var mapActionsStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [toggle3DButton, toggleAnnotationsButton])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = UIStackView.spacingUseSystem
        return sv
    }()
    
    private lazy var mapCamera: MKMapCamera = {
       MKMapCamera()
    }()
    
    private lazy var theirAnnotation : MKPointAnnotation = {
        let pa = MKPointAnnotation()
        pa.coordinate = theirLocation.coordinate
        pa.title = "Shane"
        addAnnotation(pa)
        return pa
    }()
    
    private lazy var myAnnotation: MKPointAnnotation = {
        let pa = MKPointAnnotation()
        pa.coordinate = myLocation.coordinate
        pa.title = "You"
        addAnnotation(pa)
        return pa
    }()

    init(myLocation: CLLocation = CLLocation(latitude: 37.759580, longitude: -122.391850),
         theirLocation: CLLocation = CLLocation(latitude: 33.996890, longitude: -84.428710),
         theirAddresss: CNPostalAddress? = nil,
         theirDate: Date = Date(timeIntervalSince1970: 1579947732)) {
        
        self.myLocation = myLocation
        self.theirLocation = theirLocation
        
        let pa = CNMutablePostalAddress()
        pa.street = "1884 Wood Acres Lane"
        pa.city = "Marieta"
        pa.state = "Georga"
        pa.postalCode = "30062"
        pa.country = "United States"
        
        super.init(frame: .zero)
        delegate = self

        translatesAutoresizingMaskIntoConstraints = false
        register(PersonAnnotationView.self, forAnnotationViewWithReuseIdentifier: PersonAnnotationView.id)
        
        bootstrap()
        
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
    
    deinit { removeFromSuperview() }
    
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

// MARK: - ViewBootstrappable

extension PlaybackMapView: ViewBootstrappable {
    internal func configureButtonTargets() {
        toggle3DButton.addTarget(self, action: #selector(toggleMapPreviewModeAction), for: .touchUpInside)
        toggleAnnotationsButton.addTarget(self, action: #selector(toggleAnnotationsGroupAction), for: .touchUpInside)
    }
        
    internal func configureViews() {
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
}

// MARK: - MKMapViewDelegate

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
        
//        let idx = Int.random(in: 0 ... 10)
//        let url = URL(string: "https://i.pravatar.cc/150?img=\(idx)")!
//        URLSession.shared.dataTaskPublisher(for: url)
//            .map { UIImage(data: $0.data)! }
//            .eraseToAnyPublisher()
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
//                //                print(completion)
//            }) { image in
//                view.configure(image: image)
//        }
//        .store(in: &self.cancellables)
        
        return view
    }
}
