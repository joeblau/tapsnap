// AppDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import CoreLocation
import os.log
import PencilKit
import SensorVisualizerKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.registerForRemoteNotifications()
        
        do { // Craete Inbox
            try FileManager.default.createDirectory(at: URL.inboxURL, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(at: URL.outboxURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            os_log("%@", log: .fileManager, type: .error, error.localizedDescription)
        }
        
        
        do { // Delegates
            Current.locationManager.delegate = self
            UNUserNotificationCenter.current().delegate = self
        }

        do { // Global settings
            UIView.appearance().overrideUserInterfaceStyle = .dark
            UIView.appearance(whenContainedInInstancesOf: [PKCanvasView.self]).overrideUserInterfaceStyle = .light

            UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
            UINavigationBar.appearance().shadowImage = UIImage()
            UINavigationBar.appearance().backgroundColor = .clear
            UINavigationBar.appearance().isTranslucent = true

            UIBarButtonItem.appearance().tintColor = .label
        }
        


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
            Current.locationManager.startUpdatingLocation()
        }
        CKContainer.default().loadInbox()
    }

    func application(_: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        CKContainer.default().fetchUnreadMessages { result in
            switch result {
            case .newData, .noData: CKContainer.default().loadInbox()
            default: break
            }
            completionHandler(result)
        }
    }

    // MARK: - CloudKit

    func application(_: UIApplication,
                     userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        let acceptShareOperation: CKAcceptSharesOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])

        acceptShareOperation.qualityOfService = .userInteractive
        acceptShareOperation.perShareCompletionBlock = { _, _, error in
            switch error {
            case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
            case .none: break
            }
        }
        acceptShareOperation.acceptSharesCompletionBlock = { error in
            switch error {
            case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
            case .none: break
            }

            /// Send your user to where they need to go in your app
        }
        CKContainer(identifier: cloudKitShareMetadata.containerIdentifier).add(acceptShareOperation)
    }

    // MARK: - Helpers

    private func subscribeToPushNotifications() {

    }
}
