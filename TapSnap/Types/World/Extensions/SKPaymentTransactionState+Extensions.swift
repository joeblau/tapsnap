// SKPaymentTransactionState+Extensions.swift
// Copyright (c) 2020 Tapsnap, LLC

import StoreKit

extension SKPaymentTransactionState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .purchasing: return L10n.purchasing
        case .purchased: return L10n.purchased
        case .failed: return L10n.failed
        case .restored: return L10n.restored
        case .deferred: return L10n.deferred
        @unknown default: return L10n.unknown
        }
    }
}
