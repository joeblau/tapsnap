// PlaybackViewController+MKMapViewDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import MapKit

extension PlaybackViewController: MKMapViewDelegate {
    func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }

        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.lineWidth = 3.0
//        renderer.alpha = 0.5
        renderer.strokeColor = .systemYellow

        return renderer
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MKPointAnnotation,
            let senderImage = senderImage,
            annotation.title != nil,
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: PersonAnnotationView.id,
                                                             for: annotation) as? PersonAnnotationView else {
            return nil
        }
        view.configure(image: senderImage)
        return view
    }
}
