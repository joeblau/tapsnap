// AppDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import PencilKit
import UIKit
import SensorVisualizerKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIView.appearance().overrideUserInterfaceStyle = .dark
        UIView.appearance(whenContainedInInstancesOf: [PKCanvasView.self]).overrideUserInterfaceStyle = .light

        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().isTranslucent = true

        UIBarButtonItem.appearance().tintColor = .label
    
        Current.locationManager.delegate = self
        switch UserDefaults.standard.bool(forKey: "enabled_sensor_visualizer") {
        case true: window = SensorVisualizerWindow(frame: UIScreen.main.bounds)
        case false: window = UIWindow(frame: UIScreen.main.bounds)
        }
        window?.rootViewController = RootViewController()
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Current.locationManager.requestLocation()
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Current.currentLocationSubject.send(locations.last)
    }
}
