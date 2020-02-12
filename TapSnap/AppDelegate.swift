// AppDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import MapKit
import PencilKit
import UIKit
import SensorVisualizerKit

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
    
        let window = SensorVisualizerWindow(frame: UIScreen.main.bounds)
        window.rootViewController = RootViewController()
        self.window = window
        window.makeKeyAndVisible()
        return true
    }

}
