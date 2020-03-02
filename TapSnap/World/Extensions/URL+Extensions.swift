//
//  URL+Extensions.swift
//  Tapsnap
//
//  Created by Joe Blau on 3/1/20.
//

import Foundation

extension URL {
    static var sealedURL: SealedURL {
        return (ephemeralPublicKeyURL: FileManager.default.temporaryDirectory.appendingPathComponent(NSUUID().uuidString).appendingPathExtension("dat"),
                ciphertexURL: FileManager.default.temporaryDirectory.appendingPathComponent(NSUUID().uuidString).appendingPathExtension("dat"),
                signatureURL: FileManager.default.temporaryDirectory.appendingPathComponent(NSUUID().uuidString).appendingPathExtension("dat"))
    }
    
    static var randomURL: URL {
        FileManager.default
        .temporaryDirectory
        .appendingPathComponent(NSUUID().uuidString)
        .appendingPathExtension("dat")
    }
    
    static func randomInboxSaveURL(fileExtension: FileExtension) -> URL  {
        FileManager.default
            .temporaryDirectory
            .appendingPathComponent("inbox/")
            .appendingPathComponent(NSUUID().uuidString)
            .appendingPathExtension(fileExtension.rawValue)
    }
    
    static var inboxURL: URL {
        FileManager.default
            .temporaryDirectory
            .appendingPathComponent("inbox/")
    }
}

