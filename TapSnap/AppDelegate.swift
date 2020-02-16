// AppDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import CoreLocation
import PencilKit
import SensorVisualizerKit
import UIKit
import CloudKit
import os.log

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
    
    func subscribeToPushNotifications() {
        guard !UserDefaults.standard.bool(forKey: "subscription-cached") else { return }
        
        let subscription = CKDatabaseSubscription(subscriptionID: "shared-messages-changed")
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo

        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription],
                                                       subscriptionIDsToDelete: [])
        operation.modifySubscriptionsCompletionBlock = { (savedSubscriptions, deletedSubscriptionIDs, error) in
            switch error {
            case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
            case .none: UserDefaults.standard.set(true, forKey: "subscription-cached")
            }
        }
        operation.qualityOfService = .utility
        CKContainer.default().sharedCloudDatabase.add(operation)
    }
     
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
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
}

extension AppDelegate: CLLocationManagerDelegate {
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
        print(error)
    }
}
