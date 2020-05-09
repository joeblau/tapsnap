//
//  AppDelegate+ UNUserNotificationCenterDelegate.swift
//  Tapsnap
//
//  Created by Joe Blau on 5/9/20.
//

import UIKit

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
}
