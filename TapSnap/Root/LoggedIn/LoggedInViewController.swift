// LoggedInViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit
import CoreLocation
import os.log

final class LoggedInViewController: UIViewController {
    private lazy var camera: UINavigationController = {
        let nc = UINavigationController(rootViewController: CameraViewController())
        nc.modalPresentationStyle = .fullScreen
        nc.isToolbarHidden = false
        return nc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        authorizeLocation()
        authorizeNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        present(camera, animated: false) {}
    }
    
    private func authorizeLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            Current.locationManager.requestLocation()
        }
    }
    
    private func authorizeNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (authorized, error) in
            switch error {
            case let .some(error): os_log("%@", log: .userNotification, type: .error, error.localizedDescription); return
            case .none: break
            }
            
        }
    }
}
