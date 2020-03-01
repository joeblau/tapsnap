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
    private var sharedZoneID: CKRecordZone.ID {
        CKRecordZone.ID(zoneName: "SharedZone", ownerName: CKRecordZone.ID.default.ownerName)
    }
    
    func currentUser() {
        fetchUserRecordID { [unowned self] recordID, error in
            guard self.no(error: error), let recordID = recordID else { return }
            
            let creatorReference = CKRecord.Reference(recordID: recordID, action: .none)
            CKContainer.creatorReference = creatorReference
            CKContainer.creatorPredicate = NSPredicate(format: "creatorUserRecordID == %@", creatorReference)
            
            self.fetchUser(with: recordID)
        }
    }
    
    func bootstrapKeys(reset: Bool = false) {
        do {
            let pk: Curve25519.Signing.PrivateKey? = try GenericPasswordStore().readKey(account: Current.k.privateKey)
            let pv: Curve25519.Signing.PublicKey? = try GenericPasswordStore().readKey(account: Current.k.publicKey)
            if pk == nil || pv == nil {
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
                          with media: MediaCapture,
                          completion: @escaping (_ saved: Bool)->()) {
//        let message = buildMessage(for: group)
//        switch media {
//        case let .movie(url): message[MessageKey.movie] = CKAsset(fileURL: url)
//        case let .photo(url): message[MessageKey.photo] = CKAsset(fileURL: url)
//        }
//
//        sharedCloudDatabase.save(message) { [unowned self] record, error in
//            guard self.no(error: error) else { completion(false); return }
            completion(true)
//        }
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
        let publicKey = privateKey.publicKey
        store(private: privateKey)
        store(public: publicKey)
    }
    
    private func store(private key: Curve25519.Signing.PrivateKey) {
        guard let creatorReference = CKContainer.creatorReference else { return }
        
        let query = CKQuery(recordType: .privateKey, predicate: NSPredicate(value: true))
        privateCloudDatabase.perform(query, inZoneWith: nil) { [unowned self] records, error in
            guard self.no(error: error) else { return }
            try? GenericPasswordStore().deleteKey(account: Current.k.privateKey)
            records?.forEach { [unowned self] record in
                self.privateCloudDatabase.delete(withRecordID: record.recordID) { recordID, error in
                    guard self.no(error: error) else { return }
                }
            }
            
            let record = CKRecord(recordType: .privateKey)
            record[SigningKey.key] = key.rawRepresentation
            record[SigningKey.creator] = creatorReference
            self.privateCloudDatabase.save(record) { [unowned self] record, error in
                guard self.no(error: error) else { return }
                try? GenericPasswordStore().storeKey(key, account: Current.k.privateKey)
            }
        }
    }
    
    private func store(public key: Curve25519.Signing.PublicKey) {
        guard let creatorPredicate = CKContainer.creatorPredicate,
            let creatorReference = CKContainer.creatorReference else { return }
        
        let query = CKQuery(recordType: .publicKey, predicate: creatorPredicate)
        publicCloudDatabase.perform(query, inZoneWith: nil) { [unowned self] records, error in
            guard self.no(error: error) else { return }
            try? GenericPasswordStore().deleteKey(account: Current.k.publicKey)
            records?.forEach { [unowned self] record in
                self.publicCloudDatabase.delete(withRecordID: record.recordID) { recordID, error in
                    guard self.no(error: error) else { return }
                }
            }
            
            let record = CKRecord(recordType: .publicKey)
            record[SigningKey.key] = key.rawRepresentation
            record[SigningKey.creator] = creatorReference
            self.publicCloudDatabase.save(record) { [unowned self] record, error in
                guard self.no(error: error) else { return }
                try? GenericPasswordStore().storeKey(key, account: Current.k.publicKey)
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
