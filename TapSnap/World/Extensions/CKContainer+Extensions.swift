//
//  CKContainer+Extensions.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/25/20.
//

import CloudKit
import os.lock
import UIKit
import CryptoKit

extension CKContainer {
    static var creatorReference: CKRecord.Reference?
    static var creatorPredicate: NSPredicate?
    static var recipientPredicate: NSPredicate?
    
    private var sharedZoneID: CKRecordZone.ID {
        CKRecordZone.ID(zoneName: "SharedZone", ownerName: CKRecordZone.ID.default.ownerName)
    }
    
    func currentUser() {
        fetchUserRecordID { [unowned self] recordID, error in
            guard self.no(error: error), let recordID = recordID else { return }
            
            let creatorReference = CKRecord.Reference(recordID: recordID, action: .none)
            CKContainer.creatorReference = creatorReference
            CKContainer.creatorPredicate = NSPredicate(format: "creator == %@", creatorReference)
            CKContainer.recipientPredicate = NSPredicate(format: "recipient == %@", creatorReference)
            self.fetchUser(with: recordID)
        }
    }
    
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
    
    func fetchAllFriendsWithApp() {
        discoverAllIdentities { [unowned self] identities, error in
            guard self.no(error: error) else { return }
            // TODO: Filter out current user
            Current.cloudKitFriendsSubject.send(identities)
        }
    }
    
    func createNewGroup(with name: String, from sender: UIViewController) {
        let groupRecords = buildGroup(with: name)
        
        let operation = CKModifyRecordsOperation(recordsToSave: groupRecords,
                                                 recordIDsToDelete: nil)
        operation.perRecordCompletionBlock = { [unowned self] _, error  in
            guard self.no(error: error) else { return }
        }
        operation.modifyRecordsCompletionBlock = { [unowned self] _, _, error in
            guard self.no(error: error) else { return }
            
        }
        privateCloudDatabase.add(operation)
    }
    
    func manage(group record: CKRecord, sender: UIViewController) {
        guard let shareRecordId = record.share?.recordID else { return }
        
        privateCloudDatabase.fetch(withRecordID: shareRecordId) { [unowned self] share, error in
            
            guard self.no(error: error), let share = share as? CKShare else { return }
            share[CKShare.SystemFieldKey.title] = record[GroupKey.name] as? String
            
            let thumbnailData = UIImage(systemName: "exclamationmark.triangle.fill",
                                        withConfiguration: UIImage.SymbolConfiguration(scale: .large))?
                .withTintColor(.systemOrange, renderingMode: .alwaysTemplate)
                .pngData()
            
            share[CKShare.SystemFieldKey.thumbnailImageData] =  record[GroupKey.avatar] as? NSData ?? thumbnailData
            DispatchQueue.main.async {
                let controlloer = UICloudSharingController(share: share,
                                                           container: CKContainer.default())
                controlloer.availablePermissions = [.allowPublic, .allowReadOnly]
                sender.present(controlloer, animated: true, completion: nil)
            }
        }
    }
    
    func createNewMessage(for group: CKRecord,
                          with mediaURL: URL,
                          completion: @escaping (_ saved: Bool)->()) {
        guard let shareRecordID = group.share?.recordID else {
            completion(false)
            return
        }
        
        switch group.recordID.zoneID.ownerName {
        case CKRecordZone.ID.default.ownerName:
            privateCloudDatabase.fetch(withRecordID: shareRecordID) { [unowned self] share, error in
                guard self.no(error: error), let share = share as? CKShare else { return }
                
                let participantRecordIDs = share.participants.filter { participant -> Bool in
                    !(participant.value(forKeyPath: "isCurrentUser") as? Bool ?? true)
                }.compactMap { participant -> CKRecord.ID? in
                    participant.userIdentity.userRecordID
                }
                self.sendMessages(to: participantRecordIDs, with: mediaURL, completion: completion)
            }
        default:
            sharedCloudDatabase.fetch(withRecordID: shareRecordID) { [unowned self] share, error in
                guard self.no(error: error), let share = share as? CKShare else { return }
                
                let participantRecordIDs = share.participants.filter { participant -> Bool in
                    !(participant.value(forKeyPath: "isCurrentUser") as? Bool ?? true)
                }.compactMap { participant -> CKRecord.ID? in
                    participant.userIdentity.userRecordID
                }
                
                self.sendMessages(to: participantRecordIDs, with: mediaURL, completion: completion)
            }
        }
    }
    
    func fetchAllGroups() {
        let query = CKQuery(recordType: .group, predicate: NSPredicate(value: true))
        
        sharedCloudDatabase.fetchAllRecordZones { [unowned self] zones, error in
            zones?.forEach{ zone in
                self.sharedCloudDatabase.perform(query, inZoneWith: zone.zoneID) { [unowned self] records, error in
                    guard self.no(error: error), let groups = records else { return }
                    
                    let exsitingGroups = Current.cloudKitGroupsSubject.value ?? Set<CKRecord>()
                    let newGroups = Set(groups)
                    let unionGroups = newGroups.union(exsitingGroups)
                    Current.cloudKitGroupsSubject.send(unionGroups)
                }
            }
        }
        
        privateCloudDatabase.perform(query, inZoneWith: sharedZoneID) { [unowned self] records, error in
            guard self.no(error: error), let groups = records else { return }
            
            let exsitingGroups = Current.cloudKitGroupsSubject.value ?? Set<CKRecord>()
            let newGroups = Set(groups)
            let unionGroups = newGroups.union(exsitingGroups)
            Current.cloudKitGroupsSubject.send(unionGroups)
        }
    }
    
    func fetchUnreadMessages(completion: @escaping (UIBackgroundFetchResult)->())  {
        guard let recipientPredicate = CKContainer.recipientPredicate else { return }
        let query = CKQuery(recordType: .message, predicate: recipientPredicate)
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = {  [unowned self] message in
            guard let ciphertextAsset = message[MessageKey.ciphertext] as? CKAsset,
                let ciphertextURL = ciphertextAsset.fileURL,
                let ciphertextData = try? Data(contentsOf: ciphertextURL),
                
                let signatureAsset = message[MessageKey.signature] as? CKAsset,
                let signatureURL = signatureAsset.fileURL,
                let signatureData = try? Data(contentsOf: signatureURL),
                
                let ephemeralPublicKeyAsset = message[MessageKey.media] as? CKAsset,
                let ephemeralPublicKeyURL = ephemeralPublicKeyAsset.fileURL,
                let ephemeralPublicKeyData = try? Data(contentsOf: ephemeralPublicKeyURL),
                
                let senderSigningKeyData = message[MessageKey.senderSigningKey] as? Data,
                let senderSigningKey = try? Curve25519.Signing.PublicKey(rawRepresentation: senderSigningKeyData) else {
                    fatalError("Invalid message/delete message")
            }
            let sealedMessage: SealedMessage = (ephemeralPublicKeyData: ephemeralPublicKeyData,
                                                ciphertextData: ciphertextData,
                                                signatureData: signatureData)
            self.decrypt(sealed: sealedMessage, publicKey: senderSigningKey, completed: { isSaved in
                guard isSaved else { return }
                let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [message.recordID])
                operation.modifyRecordsCompletionBlock = { [unowned self] _, _, error in
                    guard self.no(error: error) else { return }
                }
                self.publicCloudDatabase.add(operation)
            })
            completion(.newData)
        }
        operation.queryCompletionBlock = { cursor, error in
            guard self.no(error: error) else { return }
            completion(.noData)
        }
        
        publicCloudDatabase.add(operation)
    }
    
    func loadInbox() {
        do {
            let messageURLs = try FileManager.default.contentsOfDirectory(at: URL.inboxURL,
                                                                    includingPropertiesForKeys: nil,
                                                                    options: .includesDirectoriesPostOrder)
            Current.inboxURLsSubject.send(messageURLs)
        } catch {
            os_log("%@", log: .fileManager, type: .error, error.localizedDescription)
        }
    }
    
    func subscribeToInbox() {
        guard !UserDefaults.standard.bool(forKey: Current.k.subscriptionCached) else { return }
        
        publicCloudDatabase.fetchAllSubscriptions { [unowned self] subscriptions, error in
            guard self.no(error: error), let subscriptions = subscriptions else { return }
            
            guard subscriptions.isEmpty else { return }
            self.buildSubscriptions()
        }
    }
}

// MARK: - User

extension CKContainer {
    private func fetchUser(with recordID: CKRecord.ID) {
        self.privateCloudDatabase.fetch(withRecordID: recordID) { [unowned self] record, error in
            guard self.no(error: error),
                let record = record,
                let data = try? CKRecord.archive(record: record) else {
                    self.discoverUser(with: recordID)
                    return
            }
            UserDefaults.standard.set(data, forKey: Current.k.userAccount)
            Current.cloudKitUserSubject.send(record)        }
    }
    
    private func discoverUser(with recordID: CKRecord.ID) {
        self.discoverUserIdentity(withUserRecordID: recordID) { [unowned self] identity, error in
            guard self.no(error: error), let identity = identity else { return }
            self.createUser(from: identity)
        }
    }
    
    private func createUser(from identity: CKUserIdentity) {
        guard let components = identity.nameComponents else { fatalError("No identity name components") }
        
        let name = Current.formatter.personName.string(from: components)
        let user = CKRecord(recordType: .user)
        user[UserKey.name] = name
        
        self.privateCloudDatabase.save(user) { [unowned self] record, error in
            guard self.no(error: error),
                let record = record,
                let data = try? CKRecord.archive(record: record) else { return }
            
            UserDefaults.standard.set(data, forKey: Current.k.userAccount)
            Current.cloudKitUserSubject.send(record)
        }
    }
}

// MARK: - Messages

extension CKContainer {
    private func sendMessages(to participantRecordIDs: [CKRecord.ID],
                              with mediaURL: URL,
                              completion: @escaping (_ saved: Bool)->()) {
        let predecate = NSPredicate(format: "creator IN %@", participantRecordIDs)
        let query = CKQuery(recordType: .publicKey, predicate: predecate)
        self.publicCloudDatabase.perform(query, inZoneWith: nil) { [unowned self] publicKeys, error in
            guard self.no(error: error), let publicKeys = publicKeys else { return }
            
            publicKeys.forEach { publicKey in
                guard let bytes = publicKey[CryptoKey.encryption] as? Data,
                    let pkEncryption = try? Curve25519.KeyAgreement.PublicKey(rawRepresentation: bytes) else {
                        return
                }
                
                do {
                    guard let pvSigning: Curve25519.Signing.PrivateKey = try? GenericPasswordStore().readKey(account: Current.k.privateSigningKey),
                        let pkSigning: Curve25519.Signing.PublicKey = try? GenericPasswordStore().readKey(account: Current.k.publicSigningKey) else {
                            fatalError("Could not read private key/re-bootstrap")
                    }
                    let tempURL = URL.sealedURL
                    
                    let record = CKRecord(recordType: .message)
                    record[MessageKey.senderSigningKey] = pkSigning.rawRepresentation
                    let sealedMessage: SealedMessage
                    let mediaData = try Data(contentsOf: mediaURL)
                    sealedMessage = try Current.pki.encrypt(mediaData, to: pkEncryption, signedBy: pvSigning)
                    try sealedMessage.ephemeralPublicKeyData.write(to: tempURL.ephemeralPublicKeyURL)
                    record[MessageKey.media] = CKAsset(fileURL: tempURL.ephemeralPublicKeyURL)
                    
                    try sealedMessage.ciphertextData.write(to: tempURL.ciphertexURL)
                    record[MessageKey.ciphertext] = CKAsset(fileURL: tempURL.ciphertexURL)
                    try sealedMessage.signatureData.write(to: tempURL.signatureURL)
                    record[MessageKey.signature] = CKAsset(fileURL: tempURL.signatureURL)
                    record[MessageKey.recipient] = publicKey[CryptoKey.creator] as? CKRecord.Reference
                    
                    self.publicCloudDatabase.save(record) { [unowned self] record, error in
                        self.cleanUp(tempURL: tempURL)
                        guard self.no(error: error) else { return }
                        completion(true)
                    }
                } catch {
                    os_log("%@", log: .cryptoKit, type: .error, error.localizedDescription)
                }
            }
        }
    }
    
    private func cleanUp(tempURL: SealedURL) {
        [tempURL.ephemeralPublicKeyURL,
         tempURL.ciphertexURL,
         tempURL.signatureURL]
            .filter { FileManager.default.fileExists(atPath: $0.path) }
            .forEach { url in
                do {
                    try FileManager.default.removeItem(atPath: url.path)
                } catch {
                    print("Could not remove file at url: \(url)")
                }
            }
    }
}


// MARK: - Subscriptions

extension CKContainer {
    
    private func buildSubscriptions() {
        guard let recipientPredicate = CKContainer.recipientPredicate else { return }
        let subscription = CKQuerySubscription(recordType: .message,
                                               predicate: recipientPredicate,
                                               options: [.firesOnRecordCreation])
        subscription.notificationInfo = {
            let ni = CKSubscription.NotificationInfo()
            ni.shouldSendContentAvailable = true
            return ni
        }()
        
        publicCloudDatabase.save(subscription) { subscription, error in
            guard self.no(error: error) else { return }
            UserDefaults.standard.set(true, forKey: Current.k.subscriptionCached)
        }
    }

}

// MARK: - PKI

extension CKContainer {
    private func decrypt(sealed message: SealedMessage,
                         publicKey signing: Curve25519.Signing.PublicKey,
                         completed: (_ saved: Bool) -> ()) {
        guard let pvEncryption: Curve25519.KeyAgreement.PrivateKey = try? GenericPasswordStore().readKey(account: Current.k.privateEncryptionKey) else {
            fatalError("Bootstrap private encryptoin key")
        }

        do {
            let decryptedMessage = try Current.pki.decrypt(message, using: pvEncryption, from: signing)
            
            switch UIImage(data: decryptedMessage) {
            case .some(_):
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
        guard let creatorReference = CKContainer.creatorReference else { return }
        
        let query = CKQuery(recordType: .privateKey, predicate: NSPredicate(value: true))
        privateCloudDatabase.perform(query, inZoneWith: nil) { [unowned self] records, error in
            guard self.no(error: error) else { return }
            try? GenericPasswordStore().deleteKey(account: Current.k.privateEncryptionKey)
            try? GenericPasswordStore().deleteKey(account: Current.k.privateSigningKey)
            records?.forEach { [unowned self] record in
                self.privateCloudDatabase.delete(withRecordID: record.recordID) { recordID, error in
                    guard self.no(error: error) else { return }
                }
            }
            
            let record = CKRecord(recordType: .privateKey)
            record[CryptoKey.encryption] = encryption.rawRepresentation
            record[CryptoKey.signing] = signing.rawRepresentation
            record[CryptoKey.creator] = creatorReference
            self.privateCloudDatabase.save(record) { [unowned self] record, error in
                guard self.no(error: error) else { return }
                try? GenericPasswordStore().storeKey(encryption, account: Current.k.privateEncryptionKey)
                try? GenericPasswordStore().storeKey(signing, account: Current.k.privateSigningKey)
            }
        }
    }
    
    private func store(publicKey encryption: Curve25519.KeyAgreement.PublicKey,
                       publicKey signing: Curve25519.Signing.PublicKey) {
        guard let creatorPredicate = CKContainer.creatorPredicate,
            let creatorReference = CKContainer.creatorReference else { return }
        
        let query = CKQuery(recordType: .publicKey, predicate: creatorPredicate)
        publicCloudDatabase.perform(query, inZoneWith: nil) { [unowned self] records, error in
            guard self.no(error: error) else { return }
            try? GenericPasswordStore().deleteKey(account: Current.k.publicEncryptionKey)
            try? GenericPasswordStore().deleteKey(account: Current.k.publicSigningKey)
            records?.forEach { [unowned self] record in
                self.publicCloudDatabase.delete(withRecordID: record.recordID) { recordID, error in
                    guard self.no(error: error) else { return }
                }
            }
            
            let record = CKRecord(recordType: .publicKey)
            record[CryptoKey.encryption] = encryption.rawRepresentation
            record[CryptoKey.signing] = signing.rawRepresentation
            record[CryptoKey.creator] = creatorReference
            self.publicCloudDatabase.save(record) { [unowned self] record, error in
                guard self.no(error: error) else { return }
                try? GenericPasswordStore().storeKey(encryption, account: Current.k.publicEncryptionKey)
                try? GenericPasswordStore().storeKey(signing, account: Current.k.publicSigningKey)
            }
        }
    }
}

// MARK: - Group

extension CKContainer {
    private func buildGroup(with name: String) -> [CKRecord] {
        let recordID = CKRecord.ID(recordName: UUID().uuidString, zoneID: sharedZoneID)
        let group = CKRecord(recordType: .group, recordID: recordID)
        
        group[GroupKey.name] = name
        group[GroupKey.userCount] = 1
        
        let share = CKShare(rootRecord: group)
        share.publicPermission = .readOnly
        
        return [group, share]
    }
}

// MARK: - Error

extension CKContainer {
    private func no(error: Error?) -> Bool {
        switch error {
        case let .some(error):
            os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
            return false
        case .none:
            return true
        }
    }
}
