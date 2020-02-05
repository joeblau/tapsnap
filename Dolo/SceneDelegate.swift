//
//  SceneDelegate.swift
//  Dolo
//
//  Created by Joe Blau on 1/31/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit
import PencilKit
import MapKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        // Global Settings
        UIView.appearance().overrideUserInterfaceStyle = .dark
        UIView.appearance(whenContainedInInstancesOf: [PKCanvasView.self]).overrideUserInterfaceStyle = .light
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = RootViewController()
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
