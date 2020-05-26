// CKContainer+Messages.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import Combine
import CryptoKit
import os.log
import UIKit

extension CKContainer {
    static var outboxSubscriber = AnySubscriber<CKRecord, Never>()
    
    func createNewMessage(for group: CKRecord,
                          with mediaURL: MediaCapture,
                          completion: @escaping (_ saved: Bool) -> Void) {
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
                self.buildMessages(to: participantRecordIDs, with: mediaURL, completion: completion)
            }
        default:
            sharedCloudDatabase.fetch(withRecordID: shareRecordID) { [unowned self] share, error in
                guard self.no(error: error), let share = share as? CKShare else { return }
                
                let participantRecordIDs = share.participants.filter { participant -> Bool in
                    !(participant.value(forKeyPath: "isCurrentUser") as? Bool ?? true)
                }.compactMap { participant -> CKRecord.ID? in
                    participant.userIdentity.userRecordID
                }
                
                self.buildMessages(to: participantRecordIDs, with: mediaURL, completion: completion)
            }
        }
    }
    
    func sendMessages() {
        guard let sendMessages = Current.outboxRecordsSubject.value else { return }
        let operation = CKModifyRecordsOperation(recordsToSave: sendMessages, recordIDsToDelete: nil)
        operation.perRecordCompletionBlock = { [unowned self] _, error in
            guard self.no(error: error) else { return }
        }
        operation.modifyRecordsCompletionBlock = { [unowned self] _, _, error in
            guard self.no(error: error) else { return }
            Current.outboxRecordsSubject.send(nil)
            self.cleanUpEncryptedOutbox()
        }
        publicCloudDatabase.add(operation)
    }
    
    func fetchUnreadMessages(completion: ((UIBackgroundFetchResult) -> Void)? = nil) {
        guard Current.inboxURLsSubject.value != .fetching else { return }
        
        Current.inboxURLsSubject.send(.fetching)
        
        var recordIDsToDelete = [CKRecord.ID]()
        guard let recipientPredicateData = UserDefaults.standard.value(forKey: Constant.recipientPredicate) as? Data,
            let recipientPredicate = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(recipientPredicateData) as? NSPredicate else {
                currentUser(); return
        }
        let query = CKQuery(recordType: .message, predicate: recipientPredicate)
        
        let messageDownloadOperation = CKQueryOperation(query: query)
        messageDownloadOperation.recordFetchedBlock = { [unowned self] message in
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
                    return
            }
            
            let sealedMessage: SealedMessage = (ephemeralPublicKeyData: ephemeralPublicKeyData,
                                                ciphertextData: ciphertextData,
                                                signatureData: signatureData)
            
            self.decrypt(sealed: sealedMessage, publicKey: senderSigningKey)
            recordIDsToDelete.append(message.recordID)
        }
            
        messageDownloadOperation.queryCompletionBlock = { [unowned self] cursor, error in
            self.deleteMessages(messageDownloadOperation: messageDownloadOperation, recordIDsToDelete: recordIDsToDelete)
            guard self.no(error: error) else {
                completion?(.failed)
                return
            }
            completion?(.newData)
        }
        
        publicCloudDatabase.add(messageDownloadOperation)
    }
    
    private func deleteMessages(messageDownloadOperation: CKQueryOperation, recordIDsToDelete: [CKRecord.ID]) {
        let deleteMessageOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDsToDelete)
        deleteMessageOperation.perRecordCompletionBlock = { [unowned self] _, error in
            guard self.no(error: error) else { return }
        }
        deleteMessageOperation.modifyRecordsCompletionBlock = { _, _, error in
            self.loadInbox()
            guard self.no(error: error) else { return }
        }
        deleteMessageOperation.addDependency(messageDownloadOperation)
        publicCloudDatabase.add(deleteMessageOperation)
    }
    
    func loadInbox() {
        do {
            let messageURLs = try FileManager.default
                .contentsOfDirectory(at: URL.inboxURL,
                                     includingPropertiesForKeys: nil,
                                     options: .includesDirectoriesPostOrder)
                .sorted(by: { $0.lastPathComponent > $1.lastPathComponent })
            Current.inboxURLsSubject.send(.completedFetching(messageURLs))
        } catch {
            os_log("%@", log: .fileManager, type: .error, error.localizedDescription)
        }
    }
    
    func subscribeToInbox() {
        if !UserDefaults.standard.bool(forKey: Constant.messagePublicSubscriptionCached) {
            publicCloudDatabase.fetchAllSubscriptions { [unowned self] subscriptions, error in
                guard self.no(error: error), let subscriptions = subscriptions else { return }
                
                guard subscriptions.isEmpty else { return }
                self.buildMessageSubscriptions()
            }
        }
    }
    
    // MARK: - Private
    
    private func buildMessages(to participantRecordIDs: [CKRecord.ID],
                               with mediaCapture: MediaCapture,
                               completion: @escaping (_ saved: Bool) -> Void) {
        let predecate = NSPredicate(format: "creator IN %@", participantRecordIDs)
        let query = CKQuery(recordType: .publicKey, predicate: predecate)
        publicCloudDatabase.perform(query, inZoneWith: nil) { [unowned self] publicKeys, error in
            guard self.no(error: error), let publicKeys = publicKeys else { return }
            
            let sendMessages = publicKeys.compactMap { publicKey -> CKRecord? in
                guard let bytes = publicKey[CryptoKey.encryption] as? Data,
                    let pkEncryption = try? Curve25519.KeyAgreement.PublicKey(rawRepresentation: bytes) else {
                        return nil
                }
                
                do {
                    guard let pvSigning: Curve25519.Signing.PrivateKey = try? GenericPasswordStore().readKey(account: Constant.privateSigningKey),
                        let pkSigning: Curve25519.Signing.PublicKey = try? GenericPasswordStore().readKey(account: Constant.publicSigningKey) else {
                            self.bootstrapKeys()
                            return nil
                    }
                    let sealed = URL.sealedURL
                    
                    let record = CKRecord(recordType: .message)
                    
                    if let data = UserDefaults.standard.data(forKey: Constant.userAccount),
                        let userRecord = try? CKRecord.unarchive(data: data),
                        let username = userRecord[UserAliasKey.name] as? String {
                        switch mediaCapture {
                        case .movie: record[MessageKey.notification] = L10n.videoFrom(username)
                        case .photo: record[MessageKey.notification] = L10n.photoFrom(username)
                        }
                    }
                    
                    record[MessageKey.senderSigningKey] = pkSigning.rawRepresentation
                    let sealedMessage: SealedMessage
                    
                    switch mediaCapture {
                    case let .movie(url), let .photo(url):
                        let mediaData = try Data(contentsOf: url)
                        sealedMessage = try Current.pki.encrypt(mediaData, to: pkEncryption, signedBy: pvSigning)
                        try sealedMessage.ephemeralPublicKeyData.write(to: sealed.ephemeralPublicKeyURL)
                        record[MessageKey.media] = CKAsset(fileURL: sealed.ephemeralPublicKeyURL)
                    }
                    
                    try sealedMessage.ciphertextData.write(to: sealed.ciphertexURL)
                    record[MessageKey.ciphertext] = CKAsset(fileURL: sealed.ciphertexURL)
                    try sealedMessage.signatureData.write(to: sealed.signatureURL)
                    record[MessageKey.signature] = CKAsset(fileURL: sealed.signatureURL)
                    record[MessageKey.recipient] = publicKey[CryptoKey.creator] as? CKRecord.Reference
                    
                    return record
                } catch {
                    os_log("%@", log: .cryptoKit, type: .error, error.localizedDescription)
                }
                return nil
            }
            
            Current.outboxRecordsSubject.send(sendMessages)
            completion(true)
        }
    }
    
    private func cleanUpEncryptedOutbox() {
        do {
            try FileManager.default
                .contentsOfDirectory(at: URL.encryptedOutboxURL,
                                     includingPropertiesForKeys: nil,
                                     options: .includesDirectoriesPostOrder)
                .forEach { url in
                    do {
                        try FileManager.default.removeItem(atPath: url.path)
                    } catch {
                        os_log("%@", log: .fileManager, type: .error, "Could not remove file at url: \(url)")
                    }
            }
        } catch {
            os_log("%@", log: .fileManager, type: .error, error.localizedDescription)
        }
    }
    
    private func buildMessageSubscriptions() {
        guard let recipientPredicateData = UserDefaults.standard.data(forKey: Constant.recipientPredicate),
            let recipientPredicate = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(recipientPredicateData) as? NSPredicate else {
                currentUser()
                return
        }
        let subscription = CKQuerySubscription(recordType: .message,
                                               predicate: recipientPredicate,
                                               subscriptionID: UUID().uuidString,
                                               options: [CKQuerySubscription.Options.firesOnRecordCreation])
        
        subscription.notificationInfo = {
            let ni = CKSubscription.NotificationInfo()
            ni.titleLocalizationKey = "%@"
            ni.titleLocalizationArgs = ["notification"]
            ni.soundName = "default"
            ni.shouldSendContentAvailable = true
            return ni
        }()
        
        publicCloudDatabase.save(subscription) { _, error in
            guard self.no(error: error) else { return }
            UserDefaults.standard.set(true, forKey: Constant.messagePublicSubscriptionCached)
        }
        return
    }
    
    func removeAllSubscriptions() {
        publicCloudDatabase.fetchAllSubscriptions { [unowned self] subscriptions, error in
            guard self.no(error: error), let subscriptions = subscriptions else { return }
            
            subscriptions.forEach { subscription in
                self.publicCloudDatabase.delete(withSubscriptionID: subscription.subscriptionID) { _, error in
                    guard self.no(error: error) else { return }
                }
            }
        }
        
        UserDefaults.standard.removeObject(forKey: Constant.messagePublicSubscriptionCached)
    }
}
