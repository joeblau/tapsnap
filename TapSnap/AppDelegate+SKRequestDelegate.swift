// AppDelegate+SKRequestDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import os.log
import StoreKit

extension AppDelegate: SKRequestDelegate {
    func requestDidFinish(_: SKRequest) {
        fatalError("todo")
    }

    func request(_: SKRequest, didFailWithError error: Error) {
        os_log("%@", log: .storeKit, type: .error, error.localizedDescription)
    }
}
