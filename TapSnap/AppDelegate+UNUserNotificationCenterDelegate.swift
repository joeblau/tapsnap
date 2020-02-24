//
//  AppDelegate+UNUserNotificationCenterDelegate.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/23/20.
//

import UIKit

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("got one")
    }
}
