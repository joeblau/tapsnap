// AppDelegate+UNUserNotificationCenterDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter,
                                didReceive _: UNNotificationResponse,
                                withCompletionHandler _: @escaping () -> Void) {
        print("Got NOTIFICAATION")
    }
}
