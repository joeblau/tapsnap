//
//  PlaybackViewController+MKMapViewDelegate.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/8/20.
//

import MapKit

extension PlaybackViewController: MKMapViewDelegate {
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
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: PersonAnnotationView.id,
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
        .store(in: &cancellables)
        
        return view
    }
}

