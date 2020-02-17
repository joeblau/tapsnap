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

    func application(_: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let dictionary = userInfo as? [String: Any],
            let notification = CKNotification(fromRemoteNotificationDictionary: dictionary) else { return }

        switch notification.subscriptionID {
        case "shared-messages-changed":
            print("handle shared messages")
            completionHandler(.newData)
        default: break
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
        guard !UserDefaults.standard.bool(forKey: "subscription-cached") else { return }

        let subscription = CKDatabaseSubscription(subscriptionID: "shared-messages-changed")

        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo

        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription],
                                                       subscriptionIDsToDelete: [])
        operation.modifySubscriptionsCompletionBlock = { _, _, error in
            switch error {
            case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
            case .none: UserDefaults.standard.set(true, forKey: "subscription-cached")
            }
        }
        operation.qualityOfService = .utility
        CKContainer.default().sharedCloudDatabase.add(operation)
    }
}
