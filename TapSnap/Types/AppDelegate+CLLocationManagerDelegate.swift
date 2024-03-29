// AppDelegate+CLLocationManagerDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import CoreLocation
import os.log

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Current.currentLocationAuthorizationSubject.send(status)
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Current.currentLocationSubject.send(locations.last)
        guard let currentLocation = locations.last else { return }
        Current.geocoding.reverseGeocodeLocation(currentLocation) { placemarks, error in
            guard error == nil, let mark = placemarks?.first else { return }

            if let subLocality = mark.subLocality, let subAdministrativeArea = mark.subAdministrativeArea {
                let address = "\(subLocality), \(subAdministrativeArea)"
                Current.currentAddressSubject.send(address)
            } else if let city = mark.postalAddress?.city, let state = mark.postalAddress?.state {
                let address = "\(city), \(state)"
                Current.currentAddressSubject.send(address)
            }
        }
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        os_log("%@", log: .coreLocation, type: .error, error.localizedDescription)
    }
}
