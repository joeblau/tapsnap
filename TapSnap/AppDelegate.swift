// AppDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import CoreLocation
import PencilKit
import SensorVisualizerKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Current.locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            Current.locationManager.requestLocation()
        }

        UIView.appearance().overrideUserInterfaceStyle = .dark
        UIView.appearance(whenContainedInInstancesOf: [PKCanvasView.self]).overrideUserInterfaceStyle = .light

        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().isTranslucent = true

        UIBarButtonItem.appearance().tintColor = .label

        switch UserDefaults.standard.bool(forKey: "enabled_sensor_visualizer") {
        case true: window = SensorVisualizerWindow(frame: UIScreen.main.bounds)
        case false: window = UIWindow(frame: UIScreen.main.bounds)
        }
        window?.rootViewController = RootViewController()
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillEnterForeground(_: UIApplication) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            Current.locationManager.requestLocation()
        }
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Current.currentLocationSubject.send(locations.last)
        guard let currentLocation = locations.last else { return }
        Current.geocoding.reverseGeocodeLocation(currentLocation) { placemarks, error in
            guard error == nil, let mark = placemarks?.first else { return }

            if let sublocality = mark.subLocality, let subAdministrativeArea = mark.subAdministrativeArea {
                let address = "\(sublocality), \(subAdministrativeArea)"
                Current.currentAddressSubject.send(address)
            } else if let city = mark.postalAddress?.city, let state = mark.postalAddress?.state {
                let address = "\(city), \(state)"
                Current.currentAddressSubject.send(address)
            }
        }
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
