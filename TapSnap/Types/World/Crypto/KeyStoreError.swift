// KeyStoreError.swift
// Copyright (c) 2020 Tapsnap, LLC

import Foundation

/// An error we can throw when something goes wrong.
struct KeyStoreError: Error, CustomStringConvertible {
    var message: String

    init(_ message: String) {
        self.message = message
    }

    public var description: String {
        message
    }
}

extension OSStatus {
    /// A human readable message for the status.
    var message: String {
        (SecCopyErrorMessageString(self, nil) as String?) ?? String(self)
    }
}
