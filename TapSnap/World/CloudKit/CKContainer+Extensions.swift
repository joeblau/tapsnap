// CKContainer+Extensions.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import Combine
import CryptoKit
import os.log
import UIKit

extension CKContainer {
    var sharedZoneID: CKRecordZone.ID {
        CKRecordZone.ID(zoneName: "SharedZone", ownerName: CKRecordZone.ID.default.ownerName)
    }

    func no(error: Error?) -> Bool {
        switch error {
        case let .some(error):
            os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
            return false
        case .none:
            return true
        }
    }
}
