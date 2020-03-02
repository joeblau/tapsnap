// OSLog+Extensions.swift
// Copyright (c) 2020 Tapsnap, LLC

import Foundation
import os.log

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier ?? ""

    static let cloudKit = OSLog(subsystem: subsystem, category: "􀌌 CloudKit")
    static let avFoundation = OSLog(subsystem: subsystem, category: "􀍊 AVFoundation")
    static let coreLocation = OSLog(subsystem: subsystem, category: "􀋒 CoreLocation")
    static let userNotification = OSLog(subsystem: subsystem, category: "􀑐 UserNotification")
    static let cryptoKit = OSLog(subsystem: subsystem, category: "􀎡 CryptoKit")
    static let fileManager = OSLog(subsystem: subsystem, category: "􀈖 FileManager")
}
