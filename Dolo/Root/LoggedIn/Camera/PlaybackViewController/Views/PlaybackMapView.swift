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

class PlaybackMapView: MKMapView {

    let distanceLabel = UILabel()
    var cancellables = Set<AnyCancellable>()
    var distanceFormatter: MKDistanceFormatter {
        let df = MKDistanceFormatter()
        df.unitStyle = .abbreviated
        return df
    }
    let kButtonSize: CGFloat = 48
    let kButtonPadding: CGFloat = 8
    
    init() {
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        distanceLabel.adjustsFontSizeToFitWidth = true
        distanceLabel.textAlignment = .center
        distanceLabel.minimumScaleFactor = 0.6
        distanceLabel.textColor = .label

        super.init(frame: .zero)
        delegate = self
        translatesAutoresizingMaskIntoConstraints = false
        register(PersonAnnotationView.self, forAnnotationViewWithReuseIdentifier: PersonAnnotationView.id)
        
        do {
            configureViews()
        }
        
        let JOE = CLLocation(latitude: 37.759580, longitude: -122.391850)
        let SHANE = CLLocation(latitude: 33.996890, longitude: -84.428710)
        var coordinates = [JOE.coordinate, SHANE.coordinate]
        let geodesicPolyline = MKGeodesicPolyline(coordinates: &coordinates, count: coordinates.count)
        addOverlay(geodesicPolyline)
        
        let distance = JOE.distance(from: SHANE)
        let formattedDistance = distanceFormatter.string(fromDistance: distance)
        distanceLabel.text = "\(formattedDistance) between you and Shane"

        let me = MKPointAnnotation()
        me.coordinate = JOE.coordinate
        me.title = "You"
        addAnnotation(me)
        
        
        let them = MKPointAnnotation()
        them.coordinate = SHANE.coordinate
        them.title = "Shane"
        addAnnotation(them)

        showAnnotations(annotations, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Views
    
    private func configureViews() {
        addSubview(distanceLabel)
        distanceLabel.topAnchor.constraint(equalTo: topAnchor, constant: kButtonPadding).isActive = true
        distanceLabel.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        distanceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: kButtonPadding).isActive = true
        distanceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -kButtonPadding).isActive = true
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
