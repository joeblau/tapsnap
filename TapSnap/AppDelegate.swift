// AppDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import Combine
import CoreLocation
import os.log
import PencilKit
import StoreKit
import UIKit

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
            if let data = UserDefaults.standard.data(forKey: Current.k.userAccount),
                let record = try? CKRecord.unarchive(data: data) {
                Current.cloudKitUserSubject.send(record)
            }
        }
        do { // StoreKit
            SKPaymentQueue.default().add(self)
        }

        do { // Notificaions
            UIApplication.shared.registerForRemoteNotifications()
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

        do { // Visuzliser
            let hideVizualiser = UserDefaults.standard.bool(forKey: Current.k.isVisualizerHidden)
            Current.hideTouchVisuzlierSubject.send(hideVizualiser)
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
        // TODO: Figure out race condition between push notifiction and asset upload
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            CKContainer.default().fetchUnreadMessages { result in

                completionHandler(result)
            }
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
}

extension AppDelegate: ViewBootstrappable {
    func configureStreams() {
        Current.hideTouchVisuzlierSubject
            .sink { showVisualizer in
                self.sensorVisualizerWindow.visualizationWindow.isHidden = showVisualizer
                UserDefaults.standard.set(showVisualizer, forKey: Current.k.isVisualizerHidden)
            }.store(in: &cancellables)

        Current.inboxURLsSubject.sink { inboxState in
            switch inboxState {
            case let .completedFetching(urls):
                DispatchQueue.main.async {
                    UIApplication.shared.applicationIconBadgeNumber = urls?.count ?? 0
                }
            default: break
            }
        }.store(in: &cancellables)
    }
}
