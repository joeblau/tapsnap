// UNNotificationRequest+Extensions.swift
// Copyright (c) 2020 Tapsnap, LLC

import UserNotifications

extension UNNotificationRequest {
    static var noConnectivity: UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = L10n.titleNoConnectivity
        content.body = L10n.bodyNoConnectivity
        content.sound = UNNotificationSound.defaultCritical
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2,
                                                        repeats: false)

        return UNNotificationRequest(identifier: UUID().uuidString,
                                     content: content,
                                     trigger: trigger)
    }
}
