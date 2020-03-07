// GenericPasswordConvertible.swift
// Copyright (c) 2020 Tapsnap, LLC

import CryptoKit
import Foundation

/// The interface needed for SecKey conversion.
protocol GenericPasswordConvertible: CustomStringConvertible {
    /// Creates a key from a raw representation.
    init<D>(rawRepresentation data: D) throws where D: ContiguousBytes

    /// A raw representation of the key.
    var rawRepresentation: Data { get }
}

extension GenericPasswordConvertible {
    /// A string version of the key for visual inspection.
    /// IMPORTANT: Never log the actual key data.
    public var description: String {
        rawRepresentation.withUnsafeBytes { bytes in
            "Key representation contains \(bytes.count) bytes."
        }
    }
}

// Declare that the Curve25519 keys are generic passord convertible.
extension Curve25519.KeyAgreement.PrivateKey: GenericPasswordConvertible {}
extension Curve25519.KeyAgreement.PublicKey: GenericPasswordConvertible {}
extension Curve25519.Signing.PrivateKey: GenericPasswordConvertible {}
extension Curve25519.Signing.PublicKey: GenericPasswordConvertible {}

// Ensure that SymmetricKey is generic password convertible.
extension SymmetricKey: GenericPasswordConvertible {
    init<D>(rawRepresentation data: D) throws where D: ContiguousBytes {
        self.init(data: data)
    }

    var rawRepresentation: Data {
        dataRepresentation // Contiguous bytes repackaged as a Data instance.
    }
}

// Ensure that Secure Enclave keys are generic password convertible.
extension SecureEnclave.P256.KeyAgreement.PrivateKey: GenericPasswordConvertible {
    init<D>(rawRepresentation data: D) throws where D: ContiguousBytes {
        try self.init(dataRepresentation: data.dataRepresentation)
    }

    var rawRepresentation: Data {
        dataRepresentation // Contiguous bytes repackaged as a Data instance.
    }
}

extension SecureEnclave.P256.Signing.PrivateKey: GenericPasswordConvertible {
    init<D>(rawRepresentation data: D) throws where D: ContiguousBytes {
        try self.init(dataRepresentation: data.dataRepresentation)
    }

    var rawRepresentation: Data {
        dataRepresentation // Contiguous bytes repackaged as a Data instance.
    }
}

extension ContiguousBytes {
    /// A Data instance created safely from the contiguous bytes without making any copies.
    var dataRepresentation: Data {
        withUnsafeBytes { bytes in
            let cfdata = CFDataCreateWithBytesNoCopy(nil, bytes.baseAddress?.assumingMemoryBound(to: UInt8.self), bytes.count, kCFAllocatorNull)
            return ((cfdata as NSData?) as Data?) ?? Data()
        }
    }
}
