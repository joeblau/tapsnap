//
//  AppDelegate+SKRequestDelegate.swift
//  Tapsnap
//
//  Created by Joe Blau on 3/7/20.
//

import StoreKit
import os.log

extension AppDelegate: SKRequestDelegate {
    func requestDidFinish(_ request: SKRequest) {
        fatalError("todo")
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        os_log("%@", log: .storeKit, type: .error, error.localizedDescription)
    }
}
