//
//  AppDelegate+SKPaymentTransactionObserver.swift
//  Tapsnap
//
//  Created by Joe Blau on 3/7/20.
//

import StoreKit
import os.log

extension AppDelegate: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            switch transaction.transactionState {
            case .purchased, .restored:
                validatePurchase(for: transaction)
            case .failed: break // ask to rebuy
            case .deferred,
                 .purchasing:
                os_log("%@", log: .storeKit, type: .error, "StoreKit Transaction \(transaction.transactionState)")
            @unknown default:
                fatalError("Unknown StoreKit Value")
            }
        }
    }
    
    private func validatePurchase(for transaction: SKPaymentTransaction) {
        guard let url = Bundle.main.appStoreReceiptURL,
            let receipt = try? Data(contentsOf: url) else {
            os_log("%@", log: .storeKit, type: .error, "No app store receipt")
            return
        }
        
        // check bundle id
        // check bundle version
        
    }
    
    private func refreshReceipts() {
        let request = SKReceiptRefreshRequest()
        request.delegate = self
        request.start()
    }
}
