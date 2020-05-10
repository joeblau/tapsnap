// UNNotificationRequest+Extensions.swift
// Copyright (c) 2020 Tapsnap, LLC

import UserNotifications

extension UNNotificationRequest {
    static var noConnectivity: UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "No Connectivity"
        content.body = "You are currently not connected to the internet, please connect to cellular or wifi."
        content.sound = UNNotificationSound.defaultCritical
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2,
                                                        repeats: false)

        return UNNotificationRequest(identifier: UUID().uuidString,
                                     content: content,
                                     trigger: trigger)
    }
}
