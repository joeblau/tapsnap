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
    static var inbox: CKRecord?
    static var shareTitle: String?
    static var shareImage: Data?

    private var sharedZoneID: CKRecordZone.ID {
        CKRecordZone.ID(zoneName: "SharedZone", ownerName: CKRecordZone.ID.default.ownerName)
    }
    
    private var inboxZoneID: CKRecordZone.ID {
        CKRecordZone.ID(zoneName: "InboxZone", ownerName: CKRecordZone.ID.default.ownerName)
    }
    
    func currentUser() {
        fetchUserRecordID { [unowned self] recordID, error in
            guard self.no(error: error), let recordID = recordID else { return }
            self.fetchUser(with: recordID)
        }
    }
    
    func bootstrapKeys(reset: Bool = false) {
        do {
            let pk: Curve25519.Signing.PrivateKey? = try GenericPasswordStore().readKey(account: Current.k.privateKey)
            let pv: Curve25519.Signing.PublicKey? = try GenericPasswordStore().readKey(account: Current.k.publicKey)
            guard pk == nil || pv == nil else { return }
            resetKeys()
        } catch {
            os_log("%@", log: .cryptoKit, type: .error, error.localizedDescription)
        }
        
        guard reset else { return }
        resetKeys()
    }
    
    func bootstrapZones() { buildZones() }
    
    func crateInbox() {
        guard CKContainer.inbox == nil else { return }
        let inboxQuery = CKQuery(recordType: .inbox, predicate: NSPredicate(value: true))
        privateCloudDatabase.perform(inboxQuery, inZoneWith: inboxZoneID) { [unowned self] records, error in
            guard self.no(error: error) else { self.buildInbox(); return }
            
            switch records?.first {
            case let .some(inbox): CKContainer.inbox = inbox
            case .none: self.buildInbox()
            }
        }
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
        CKContainer.shareTitle = record[GroupKey.name] as? String
        CKContainer.shareImage = UIImage(systemName: "video.fill")?.pngData()
         
        privateCloudDatabase.fetch(withRecordID: shareRecordId) { [unowned self] share, error in
            
            guard self.no(error: error), let share = share as? CKShare else { return }
            
            DispatchQueue.main.async {
                let controlloer = UICloudSharingController(share: share,
                                                           container: CKContainer.default())
                controlloer.availablePermissions = [.allowPublic, .allowReadOnly]
                controlloer.delegate = self
                sender.present(controlloer, animated: true, completion: nil)
            }
        }
    }
    
//    func share(group share: CKShare, in container: CKContainer, sender: UIViewController) {
//        DispatchQueue.main.async {
//        let controller = UICloudSharingController(share: share, container: container)
//        controller.availablePermissions = [.allowPublic, .allowReadOnly]
//        controller.delegate = self
//        sender.present(controller, animated: true, completion: nil)
//        }
//    }
    
    func createNewMessage(for group: CKRecord,
                          with media: MediaCapture,
                          completion: @escaping (_ saved: Bool)->()) {
        let message = buildMessage(for: group)
        switch media {
        case let .movie(url): message[MessageKey.movie] = CKAsset(fileURL: url)
        case let .photo(url): message[MessageKey.photo] = CKAsset(fileURL: url)
        }
        
        sharedCloudDatabase.save(message) { [unowned self] record, error in
            guard self.no(error: error) else { completion(false); return }
            completion(true)
        }
    }
    
    func fetchAllGroups() {
        let query = CKQuery(recordType: .group, predicate: NSPredicate(value: true))

        privateCloudDatabase.perform(query, inZoneWith: sharedZoneID) { [unowned self] records, error in
            guard self.no(error: error), let groups = records else { return }
            Current.cloudKitGroupsSubject.send(Set<CKRecord>(groups))
        }
    }
    
    func fetchUnreadMessages() {
//        let query = CKQuery(recordType: .message, predicate: NSPredicate(value: true))
//
//        sharedCloudDatabase.perform(query, inZoneWith: sharedZoneID) { [unowned self] records, error in
//            guard self.no(error: error) else { return }
//            //            print(records)
//        }
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

// MARK: - PKI

extension CKContainer {
    
    private func resetKeys() {
        let privateKey = Curve25519.Signing.PrivateKey()
        try? GenericPasswordStore().storeKey(privateKey, account: Current.k.privateKey)
        let publicKey = privateKey.publicKey
        try? GenericPasswordStore().storeKey(publicKey, account: Current.k.publicKey)
        let newPrivateRecord = store(private: privateKey)
        let newPublicRecords = store(public: publicKey)
        let operation = CKModifyRecordsOperation(recordsToSave: [newPrivateRecord] + newPublicRecords,
                                                 recordIDsToDelete: nil)
        operation.perRecordCompletionBlock = { [unowned self] _, error  in
            guard self.no(error: error) else { return }
        }
        operation.modifyRecordsCompletionBlock = { [unowned self] _, _, error in
            guard self.no(error: error) else { return }
        }
        
        clearExistingKeys().forEach { clearOperation in
            operation.addDependency(clearOperation)
            privateCloudDatabase.add(clearOperation)
        }
        
        privateCloudDatabase.add(operation)
    }
    
    private func store(private key: Curve25519.Signing.PrivateKey) -> CKRecord {
        let privateKeyRecord = CKRecord(recordType: .privateKey)
        privateKeyRecord[SigningKey.key] = key.rawRepresentation
        return privateKeyRecord
    }
    
    private func store(public key: Curve25519.Signing.PublicKey) -> [CKRecord] {
        let recordID = CKRecord.ID(recordName: UUID().uuidString, zoneID: sharedZoneID)
        let publicKeyRecord = CKRecord(recordType: .publicKey, recordID: recordID)
        publicKeyRecord[SigningKey.key] = key.rawRepresentation
        
        let shareRecord = CKShare(rootRecord: publicKeyRecord)
        shareRecord.publicPermission = .readOnly
        return [publicKeyRecord, shareRecord]
    }
    
    private func clearExistingKeys() -> [CKQueryOperation] {
        let privateKeyQuery = CKQuery(recordType: .privateKey, predicate: NSPredicate(value: true))
        let privateOperation = CKQueryOperation(query: privateKeyQuery)
        privateOperation.recordFetchedBlock = { [unowned self] record in
            self.privateCloudDatabase.delete(withRecordID: record.recordID) { [unowned self] recordID, error in
                guard self.no(error: error) else { return }
                try? GenericPasswordStore().deleteKey(account: Current.k.privateKey)
            }
        }
        
        let publicKeyQuery = CKQuery(recordType: .publicKey, predicate: NSPredicate(value: true))
        let publicOperation = CKQueryOperation(query: publicKeyQuery)
        publicOperation.recordFetchedBlock = { [unowned self] record in
            self.privateCloudDatabase.delete(withRecordID: record.recordID) { [unowned self] recordID, error in
                guard self.no(error: error) else { return }
                try? GenericPasswordStore().deleteKey(account: Current.k.publicKey)
            }
        }
        return [privateOperation, publicOperation]
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

// MARK: - Messages

extension CKContainer {
    private func buildMessage(for group: CKRecord) -> CKRecord {
        let recordID = CKRecord.ID(recordName: UUID().uuidString, zoneID: sharedZoneID)
        let message = CKRecord(recordType: .message, recordID: recordID)
        return message
    }
}

// MARK: - Inbox

extension CKContainer {
    private func buildInbox() {
        let recordID = CKRecord.ID(recordName: UUID().uuidString, zoneID: inboxZoneID)
        let inboxRecord = CKRecord(recordType: .inbox, recordID: recordID)

        let shareRecord = CKShare(rootRecord: inboxRecord)
        shareRecord.publicPermission = .readWrite

        let operation = CKModifyRecordsOperation(recordsToSave: [inboxRecord, shareRecord],
                                                 recordIDsToDelete: nil)
        operation.perRecordCompletionBlock = { [unowned self] _, error  in
            guard self.no(error: error) else { return }
        }
        operation.modifyRecordsCompletionBlock = { [unowned self] _, _, error in
            guard self.no(error: error) else { return }
        }
        privateCloudDatabase.add(operation)
    }
}

// MARK: - Zones

extension CKContainer {
    private func buildZones() {
        privateCloudDatabase.fetchAllRecordZones { [unowned self] zones, error in
            let sharedZoneEmpty = zones?.filter { $0.zoneID.zoneName == self.sharedZoneID.zoneName }.isEmpty ?? true
            if sharedZoneEmpty {
                self.privateCloudDatabase.save(CKRecordZone(zoneID: self.sharedZoneID)) { [unowned self] zone, error in
                    guard self.no(error: error) else { return }
                }
            }

            let inboxZoneEmpty = zones?.filter { $0.zoneID.zoneName == self.inboxZoneID.zoneName }.isEmpty ?? true
            if inboxZoneEmpty {
                self.privateCloudDatabase.save(CKRecordZone(zoneID: self.inboxZoneID)) { [unowned self] zone, error in
                    guard self.no(error: error) else { return }
                }
            }
        }
    }
}

// MARK: - Error

extension CKContainer {
    private func no(error: Error?) -> Bool {
        switch error {
        case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription); return false
        case .none: return true
        }
    }
}
