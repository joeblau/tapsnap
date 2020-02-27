//
//  CKContainer+Extensions.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/25/20.
//

import CloudKit
import os.lock
import UIKit

extension CKContainer {
    private var zoneID: CKRecordZone.ID {
        CKRecordZone.ID(zoneName: "SharedZone", ownerName: CKRecordZone.ID.default.ownerName)
    }
    
    func currentUser() {
        fetchUserRecordID { recordID, error in
            guard self.no(error: error), let recordID = recordID else { return }
            self.fetchUser(with: recordID)
        }
    }
    
    func fetchAllFriendsWithApp() {
        discoverAllIdentities { identities, error in
            guard self.no(error: error) else { return }
            // TODO: Filter out current user
            Current.cloudKitFriendsSubject.send(identities)
        }
    }
    
    func createNewGroup(with name: String, from sender: UIViewController) {
        let groupRecords = buildGroup(with: name)
        let operation = CKModifyRecordsOperation(recordsToSave: groupRecords,
                                                 recordIDsToDelete: nil)
        operation.perRecordCompletionBlock = { _, error  in
            guard self.no(error: error) else { return }
        }
        operation.modifyRecordsCompletionBlock = { _, _, error in
            guard self.no(error: error) else { return }
            
        }
        privateCloudDatabase.add(operation)
    }
    
    func share(group share: CKShare, in container: CKContainer, sender: UIViewController) {
        let controller = UICloudSharingController(share: share, container: container)
        controller.availablePermissions = [.allowPrivate, .allowReadWrite]
        controller.delegate = self
        sender.present(controller, animated: true) {}
    }
    
    func createNewMessage(for group: CKRecord,
                          with media: MediaCapture,
                          completion: @escaping (_ saved: Bool)->()) {
        let message = buildMessage(for: group)
        switch media {
        case let .movie(url): message[MessageKey.movie] = CKAsset(fileURL: url)
        case let .photo(url): message[MessageKey.photo] = CKAsset(fileURL: url)
        }
        
        sharedCloudDatabase.save(message) { record, error in
            guard self.no(error: error) else { completion(false); return }
            completion(true)
        }
    }
    
    func fetchAllGroups() {
        let query = CKQuery(recordType: .group, predicate: NSPredicate(value: true))
        
        privateCloudDatabase.perform(query, inZoneWith: zoneID) { records, error in
            guard self.no(error: error), let groups = records else { return }
            
            let currentGroups = Current.cloudKitGroupsSubject.value ?? Set<CKRecord>()
            let allGroups = currentGroups.union(groups)
            Current.cloudKitGroupsSubject.send(allGroups)
        }
    }
    
    func fetchUnreadMessages() {
        let query = CKQuery(recordType: .message, predicate: NSPredicate(value: true))
        
        sharedCloudDatabase.perform(query, inZoneWith: zoneID) { records, error in
            guard self.no(error: error) else { return }
//            print(records)
        }
    }
}

// MARK: - User

extension CKContainer {
    private func fetchUser(with recordID: CKRecord.ID) {
        self.privateCloudDatabase.fetch(withRecordID: recordID) { record, error in
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
        self.discoverUserIdentity(withUserRecordID: recordID) { identity, error in
            guard self.no(error: error), let identity = identity else { return }
            self.createUser(from: identity)
        }
    }
    
    private func createUser(from identity: CKUserIdentity) {
        guard let components = identity.nameComponents else { fatalError("No identity name components") }
        
        let name = Current.formatter.personName.string(from: components)
        let user = CKRecord(recordType: .user)
        user[UserKey.name] = name
        
        self.privateCloudDatabase.save(user) { record, error in
            guard self.no(error: error),
                let record = record,
                let data = try? CKRecord.archive(record: record) else { return }
            
            UserDefaults.standard.set(data, forKey: Current.k.userAccount)
            Current.cloudKitUserSubject.send(record)
        }
    }
}

// MARK: - Group

extension CKContainer {
    func buildGroup(with name: String) -> [CKRecord] {
        let recordID = CKRecord.ID(recordName: UUID().uuidString, zoneID: zoneID)
        let group = CKRecord(recordType: .group, recordID: recordID)
        
        group[GroupKey.name] = name
        group[GroupKey.userCount] = 1
        
        let share = CKShare(rootRecord: group)
        return [group, share]
    }
}

// MARK: - Messages

extension CKContainer {
    func buildMessage(for group: CKRecord) -> CKRecord {
        let recordID = CKRecord.ID(recordName: UUID().uuidString, zoneID: zoneID)
        let message = CKRecord(recordType: .message, recordID: recordID)
        return message
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
