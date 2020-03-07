// URL+Extensions.swift
// Copyright (c) 2020 Tapsnap, LLC

import Foundation

extension URL {
    static var sealedURL: SealedURL {
        (ephemeralPublicKeyURL: randomEncryptedOutboxSaveURL(with: .dat),
         ciphertexURL: randomEncryptedOutboxSaveURL(with: .dat),
         signatureURL: randomEncryptedOutboxSaveURL(with: .dat))
    }

    static var randomURL: URL {
        FileManager.default
            .temporaryDirectory
            .appendingPathComponent(NSUUID().uuidString)
            .appendingPathExtension("dat")
    }

    // MARK: - Inbox

    static func randomInboxSaveURL(fileExtension: FileExtension) -> URL {
        FileManager.default
            .temporaryDirectory
            .appendingPathComponent("inbox/")
            .appendingPathComponent(dateUUID)
            .appendingPathExtension(fileExtension.rawValue)
    }

    static var inboxURL: URL {
        FileManager.default
            .temporaryDirectory
            .appendingPathComponent("inbox/")
    }

    // MARK: - Encrypted Outbox

    static func randomEncryptedOutboxSaveURL(with fileExtension: FileExtension) -> URL {
        FileManager.default
            .temporaryDirectory
            .appendingPathComponent("encrypted-outbox/")
            .appendingPathComponent(dateUUID)
            .appendingPathExtension(fileExtension.rawValue)
    }

    static var encryptedOutboxURL: URL {
        FileManager.default
            .temporaryDirectory
            .appendingPathComponent("encrypted-outbox/")
    }

    // MARK: - Outbox

    static func randomOutboxSaveURL(with fileExtension: FileExtension) -> URL {
        FileManager.default
            .temporaryDirectory
            .appendingPathComponent("outbox/")
            .appendingPathComponent(dateUUID)
            .appendingPathExtension(fileExtension.rawValue)
    }

    static var outboxURL: URL {
        FileManager.default
            .temporaryDirectory
            .appendingPathComponent("outbox/")
    }

    // MARK: - Private

    private static var dateUUID: String {
        "\(Date().timeIntervalSince1970)-\(NSUUID().uuidString)"
    }
}
