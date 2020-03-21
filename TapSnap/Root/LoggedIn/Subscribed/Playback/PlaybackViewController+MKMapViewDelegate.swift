// PlaybackViewController+MKMapViewDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import MapKit

extension PlaybackViewController: MKMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        reloadOverlays(mapView: mapView)
    }

    func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }

        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.lineWidth = 3.0
        renderer.strokeColor = .systemYellow

        return renderer
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation is MKUserLocation {
        case true:
            return nil
        case false:
            let pin = MKPinAnnotationView()
            pin.animatesDrop = true
            pin.pinTintColor = .systemYellow
            return mapView.dequeueReusableAnnotationView(withIdentifier: MKPinAnnotationView.id) ?? pin
        }
    }

    func mapView(_ mapView: MKMapView, didUpdate _: MKUserLocation) {
        reloadOverlays(mapView: mapView)
    }

    private func reloadOverlays(mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)

        guard let theirCoordinate = mapView.annotations
            .first(where: { !($0 is MKUserLocation) })?
            .coordinate else { return }

        var coordinates = [theirCoordinate, mapView.userLocation.coordinate]
        let geodesicPolyline = MKGeodesicPolyline(coordinates: &coordinates, count: coordinates.count)
        mapView.addOverlay(geodesicPolyline)
    }
}
