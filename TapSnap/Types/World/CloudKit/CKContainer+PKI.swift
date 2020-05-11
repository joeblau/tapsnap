// CKContainer+PKI.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import CryptoKit
import os.log
import UIKit

extension CKContainer {
    func bootstrapKeys(reset: Bool = false) {
        do {
            let pvEncryption: Curve25519.KeyAgreement.PrivateKey? = try GenericPasswordStore().readKey(account: Current.k.privateEncryptionKey)
            let pkEncryption: Curve25519.KeyAgreement.PublicKey? = try GenericPasswordStore().readKey(account: Current.k.publicEncryptionKey)
            let pvSigning: Curve25519.Signing.PrivateKey? = try GenericPasswordStore().readKey(account: Current.k.privateSigningKey)
            let pkSigning: Curve25519.Signing.PublicKey? = try GenericPasswordStore().readKey(account: Current.k.publicSigningKey)
            if pvEncryption == nil || pkEncryption == nil || pvSigning == nil || pkSigning == nil {
                resetKeys()
            }
        } catch {
            os_log("%@", log: .cryptoKit, type: .error, error.localizedDescription)
        }

        guard reset else { return }
        resetKeys()
    }

    func decrypt(sealed message: SealedMessage,
                 publicKey signing: Curve25519.Signing.PublicKey,
                 completed: (_ saved: Bool) -> Void) {
        guard let pvEncryption: Curve25519.KeyAgreement.PrivateKey = try? GenericPasswordStore().readKey(account: Current.k.privateEncryptionKey) else {
            fatalError("Bootstrap private encryptoin key")
        }

        do {
            let decryptedMessage = try Current.pki.decrypt(message, using: pvEncryption, from: signing)

            switch UIImage(data: decryptedMessage) {
            case .some:
                try decryptedMessage.write(to: URL.randomInboxSaveURL(fileExtension: .heic), options: .atomicWrite)
            case .none:
                try decryptedMessage.write(to: URL.randomInboxSaveURL(fileExtension: .mov), options: .atomicWrite)
            }
            completed(true)
        } catch {
            completed(false)
            os_log("%@", log: .cryptoKit, type: .error, error.localizedDescription)
        }
    }

    // MARK: - Private

    private func resetKeys() {
        let pvEncryption = Curve25519.KeyAgreement.PrivateKey()
        let pkEncryption = pvEncryption.publicKey

        let pvSigning = Curve25519.Signing.PrivateKey()
        let pkSigning = pvSigning.publicKey

        store(privateKey: pvEncryption, privateKey: pvSigning)
        store(publicKey: pkEncryption, publicKey: pkSigning)
    }

    private func store(privateKey encryption: Curve25519.KeyAgreement.PrivateKey,
                       privateKey signing: Curve25519.Signing.PrivateKey) {
        guard let creatorReferenceData = UserDefaults.standard.data(forKey: Current.k.creatorReference),
            let creatorReference = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(creatorReferenceData) as? CKRecord.Reference else {
            currentUser(); return
        }

        let query = CKQuery(recordType: .privateKey, predicate: NSPredicate(value: true))
        privateCloudDatabase.perform(query, inZoneWith: nil) { [unowned self] records, error in
            guard self.no(error: error) else { return }
            try? GenericPasswordStore().deleteKey(account: Current.k.privateEncryptionKey)
            try? GenericPasswordStore().deleteKey(account: Current.k.privateSigningKey)
            records?.forEach { [unowned self] record in
                self.privateCloudDatabase.delete(withRecordID: record.recordID) { _, error in
                    guard self.no(error: error) else { return }
                }
            }

            let record = CKRecord(recordType: .privateKey)
            record[CryptoKey.encryption] = encryption.rawRepresentation
            record[CryptoKey.signing] = signing.rawRepresentation
            record[CryptoKey.creator] = creatorReference
            self.privateCloudDatabase.save(record) { [unowned self] _, error in
                guard self.no(error: error) else { return }
                try? GenericPasswordStore().storeKey(encryption, account: Current.k.privateEncryptionKey)
                try? GenericPasswordStore().storeKey(signing, account: Current.k.privateSigningKey)
            }
        }
    }

    private func store(publicKey encryption: Curve25519.KeyAgreement.PublicKey,
                       publicKey signing: Curve25519.Signing.PublicKey) {
        guard let creatorPredicateData = UserDefaults.standard.data(forKey: Current.k.creatorPredicate),
            let creatorPredicate = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(creatorPredicateData) as? NSPredicate,
            let creatorReferenceData = UserDefaults.standard.data(forKey: Current.k.creatorReference),
            let creatorReference = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(creatorReferenceData) as? CKRecord.Reference else {
            currentUser(); return
        }

        let query = CKQuery(recordType: .publicKey, predicate: creatorPredicate)
        publicCloudDatabase.perform(query, inZoneWith: nil) { [unowned self] records, error in
            guard self.no(error: error) else { return }
            try? GenericPasswordStore().deleteKey(account: Current.k.publicEncryptionKey)
            try? GenericPasswordStore().deleteKey(account: Current.k.publicSigningKey)
            records?.forEach { [unowned self] record in
                self.publicCloudDatabase.delete(withRecordID: record.recordID) { _, error in
                    guard self.no(error: error) else { return }
                }
            }

            let record = CKRecord(recordType: .publicKey)
            record[CryptoKey.encryption] = encryption.rawRepresentation
            record[CryptoKey.signing] = signing.rawRepresentation
            record[CryptoKey.creator] = creatorReference
            self.publicCloudDatabase.save(record) { [unowned self] _, error in
                guard self.no(error: error) else { return }
                try? GenericPasswordStore().storeKey(encryption, account: Current.k.publicEncryptionKey)
                try? GenericPasswordStore().storeKey(signing, account: Current.k.publicSigningKey)
            }
        }
    }
}
