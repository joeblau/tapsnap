// AppDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import Combine
import CoreLocation
import os.log
import PencilKit
import StoreKit
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var cancellables = Set<AnyCancellable>()
    lazy var sensorVisualizerWindow: SensorVisualizerWindow = {
        SensorVisualizerWindow(frame: UIScreen.main.bounds,
                               primary: .systemBlue,
                               secondary: .systemBlue)
    }()

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        bootstrap()

        do { // Bootstrap user
            if let data = UserDefaults.standard.data(forKey: Constant.userAccount),
                let record = try? CKRecord.unarchive(data: data) {
                Current.cloudKitUserSubject.send(record)
            }
        }

        do { // StoreKit
            SKPaymentQueue.default().add(self)
        }

        do { // Notificaions
            UIApplication.shared.registerForRemoteNotifications()
            UNUserNotificationCenter.current().delegate = self
        }

        
        do { // CloudKit
            try FileManager.default.createDirectory(at: URL.inboxURL, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(at: URL.outboxURL, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(at: URL.encryptedOutboxURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            os_log("%@", log: .fileManager, type: .error, error.localizedDescription)
        }

        do { // Delegates
            Current.locationManager.delegate = self
        }

        do { // Location
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                Current.locationManager.startMonitoringSignificantLocationChanges()
            }
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

        window = sensorVisualizerWindow
        window?.rootViewController = RootViewController()
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillEnterForeground(_: UIApplication) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            Current.locationManager.startMonitoringSignificantLocationChanges()
        }
        CKContainer.default().fetchUnreadMessages()
    }

    func application(_: UIApplication,
                     didReceiveRemoteNotification _: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            CKContainer.default().fetchUnreadMessages { result in
                completionHandler(result)
            }
        }
    }

    // MARK: - CloudKit

    func application(_: UIApplication,
                     userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        let acceptShareOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])

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
        }
        CKContainer(identifier: cloudKitShareMetadata.containerIdentifier).add(acceptShareOperation)
    }
}

extension AppDelegate: ViewBootstrappable {
    func configureStreams() {
        Current.showTouchVisuzlierSubject
            .receive(on: DispatchQueue.main)
            .sink { showVisualizer in
                self.sensorVisualizerWindow
                    .visualizationWindow
                    .isHidden = !showVisualizer
            }.store(in: &cancellables)

        Current.inboxURLsSubject
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { inboxState in
                switch inboxState {
                case let .completedFetching(urls):
                    switch urls {
                    case let .some(urls): UIApplication.shared.applicationIconBadgeNumber = urls.count
                    case .none: UIApplication.shared.applicationIconBadgeNumber = 0
                    }
                default: break
                }
            }.store(in: &cancellables)

        Current.reachability
            .reachabilitySubject
            .sink { status in
                switch status {
                case .offline:
                    UNUserNotificationCenter.current()
                        .add(UNNotificationRequest.noConnectivity)
                case .online, .unknown: break
                }
            }.store(in: &cancellables)
    }
}
