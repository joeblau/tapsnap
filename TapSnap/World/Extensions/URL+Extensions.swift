//
//  URL+Extensions.swift
//  Tapsnap
//
//  Created by Joe Blau on 3/1/20.
//

import Foundation

extension URL {
    static var sealedURL: SealedURL {
        let ephemeralPublicKeyPath = (NSTemporaryDirectory() as NSString).appendingPathComponent((NSUUID().uuidString as NSString).appendingPathExtension("dat")!)
        let ciphertextPath = (NSTemporaryDirectory() as NSString).appendingPathComponent((NSUUID().uuidString as NSString).appendingPathExtension("dat")!)
        let signaturePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((NSUUID().uuidString as NSString).appendingPathExtension("dat")!)
        
        return (ephemeralPublicKeyURL: URL(fileURLWithPath: ephemeralPublicKeyPath),
                ciphertexURL: URL(fileURLWithPath: ciphertextPath),
                signatureURL: URL(fileURLWithPath: signaturePath))
    }
}

