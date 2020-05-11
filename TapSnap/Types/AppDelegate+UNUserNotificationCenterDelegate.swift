// AppDelegate+UNUserNotificationCenterDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter,
                                willPresent _: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}
