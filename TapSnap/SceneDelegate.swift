// SceneDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import MapKit
import PencilKit
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        // Global Settings
        UIView.appearance().overrideUserInterfaceStyle = .dark
        UIView.appearance(whenContainedInInstancesOf: [PKCanvasView.self]).overrideUserInterfaceStyle = .light

        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().isTranslucent = true

        UIBarButtonItem.appearance().tintColor = .label

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = RootViewController()
        self.window = window
        window.makeKeyAndVisible()
    }
}
