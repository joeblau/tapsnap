// LoggedInViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import CoreLocation
import os.log
import UIKit

final class LoggedInViewController: UIViewController {
    private lazy var camera: UINavigationController = {
        let nc = UINavigationController(rootViewController: CameraViewController())
        nc.modalPresentationStyle = .fullScreen
        nc.isToolbarHidden = false
        return nc
    }()
    
    private lazy var subscription: UINavigationController = {
        let nc = UINavigationController(rootViewController: SubscriptionViewController())
        nc.modalPresentationStyle = .fullScreen
        return nc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        CKContainer.default().bootstrapKeys()
        CKContainer.default().fetchAllGroups()
        authorizeLocation()
        authorizeNotifications()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            CKContainer.default().fetchUnreadMessages { result in
                CKContainer.default().loadInbox()
            }
            CKContainer.default().subscribeToInbox()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        present(camera, animated: false) {}
//        present(subscription, animated: false) {}
    }

    private func authorizeLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            Current.locationManager.requestLocation()
        }
    }

    private func authorizeNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, error in
            switch error {
            case let .some(error): os_log("%@", log: .userNotification, type: .error, error.localizedDescription); return
            case .none: break
            }
        }
    }
}
