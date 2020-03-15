// SKPaymentTransactionState+Extensions.swift
// Copyright (c) 2020 Tapsnap, LLC

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
