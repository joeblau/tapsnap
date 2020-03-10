//
//  SKPaymentTransactionState+Extensions.swift
//  Tapsnap
//
//  Created by Joe Blau on 3/7/20.
//

import StoreKit

extension SKPaymentTransactionState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .purchasing: return "Purchasing"
        case .purchased: return "Purchased"
        case .failed: return "Failed"
        case .restored: return "Restored"
        case .deferred: return "Deferred"
        @unknown default: return "Unknown"
        }
    }
}
