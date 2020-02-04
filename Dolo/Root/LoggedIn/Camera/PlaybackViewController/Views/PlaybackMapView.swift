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
    var cancellables = Set<AnyCancellable>()
    
    let kButtonSize: CGFloat = 48
    let kButtonPadding: CGFloat = 8
    
    
    init(myLocation: CLLocation = CLLocation(latitude: 37.759580, longitude: -122.391850),
         theirLocatoin: CLLocation = CLLocation(latitude: 33.996890, longitude: -84.428710),
         theirAddresss: CNPostalAddress? = nil,
         theirDate: Date = Date(timeIntervalSince1970: 1579947732)) {
        
        let distance = myLocation.distance(from: theirLocatoin)
        
        let pa = CNMutablePostalAddress()
        pa.street = "1884 Wood Acres Lane"
        pa.city = "Marieta"
        pa.state = "Georga"
        pa.postalCode = "30062"
        pa.country = "United States"

        
        timeDistanceLocation.translatesAutoresizingMaskIntoConstraints = false
        timeDistanceLocation.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        timeDistanceLocation.adjustsFontSizeToFitWidth = true
        timeDistanceLocation.minimumScaleFactor = 0.6
        timeDistanceLocation.numberOfLines = 0
        timeDistanceLocation.textColor = .label
        
        super.init(frame: .zero)
        delegate = self
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        register(PersonAnnotationView.self, forAnnotationViewWithReuseIdentifier: PersonAnnotationView.id)
        
        do {
            configureViews()
        }
        
        var coordinates = [myLocation.coordinate, theirLocatoin.coordinate]
        let geodesicPolyline = MKGeodesicPolyline(coordinates: &coordinates, count: coordinates.count)
        addOverlay(geodesicPolyline)
        
        let me = MKPointAnnotation()
        me.coordinate = myLocation.coordinate
        me.title = "You"
        addAnnotation(me)
        
        
        let them = MKPointAnnotation()
        them.coordinate = theirLocatoin.coordinate
        them.title = "Shane"
        addAnnotation(them)
        
        showAnnotations([annotations.first!], animated: true)
        timeDistanceLocation.attributedText = formatMetadata(address: pa,
                                                             date: theirDate,
                                                             distance: distance)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Views
    
    private func configureViews() {
        addSubview(timeDistanceLocation)
        timeDistanceLocation.topAnchor.constraint(equalTo: topAnchor, constant: kButtonPadding).isActive = true
        timeDistanceLocation.heightAnchor.constraint(greaterThanOrEqualToConstant: kButtonSize).isActive = true
        timeDistanceLocation.leadingAnchor.constraint(equalTo: leadingAnchor, constant: kButtonPadding).isActive = true
        timeDistanceLocation.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -kButtonPadding).isActive = true
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
