//
//  OSLog+Extensions.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/16/20.
//

import Foundation
import os.log

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier ?? ""
    
    static let cloudKit = OSLog(subsystem: subsystem, category: "􀌌 CloudKit")
    static let avFoundation = OSLog(subsystem: subsystem, category: "􀍊 AVFoundation")
    static let coreLocation = OSLog(subsystem: subsystem, category: "􀋒 CoreLocation")
}
