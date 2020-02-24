// CloudKitManager.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import Combine
import os.log
import UIKit

class CloudKitManager: NSObject {
    private let sharedMessageZone = CKRecordZone(zoneName: "SharedZone")
    override init() {
        super.init()
        setupZones()
        fetchAllZones()
//        createSubscription()
    }

    func fetchCurrentUser() {
        CKContainer.default().fetchUserRecordID { recordID, error in
            switch error {
            case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription); return
            case .none: break
            }

            guard let recordID = recordID else { return }
            self.fetchUserRecord(with: recordID)
        }
    }

    func createNewUser(from identity: CKUserIdentity) {
        guard let identityComponents = identity.nameComponents else { return }

        let name = Current.formatter.personName.string(from: identityComponents)

        let userRecord = CKRecord(recordType: .user)
        userRecord[UserKey.name.rawValue] = name

        CKContainer.default()
            .privateCloudDatabase
            .save(userRecord) { _, error in
                switch error {
                case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription); return
                case .none: break
                }

                guard let recordData = try? CKRecord.archive(record: userRecord) else {
                    return
                }
                UserDefaults.standard.set(recordData, forKey: Current.k.userAccount)
                Current.cloudKitUserSubject.send(userRecord)
            }
    }
    
    func createNewMessage(for group: CKRecord, with media: MediaCapture, completion: @escaping (_ saved: Bool)->()) {
        let zoneID = CKRecordZone.ID(zoneName: "SharedZone", ownerName: CKRecordZone.ID.default.ownerName)
        let recordID = CKRecord.ID(recordName: "New Message", zoneID: zoneID)
        let messageRecord = CKRecord(recordType: .message, recordID: recordID)
        messageRecord.setParent(group)
        
        switch media {
        case let .movie(url):
            messageRecord[MessageKey.movie.rawValue] = CKAsset(fileURL: url)
        case let .photo(url):
            messageRecord[MessageKey.photo.rawValue] = CKAsset(fileURL: url)
        }
        
        CKContainer.default()
            .privateCloudDatabase
            .save(messageRecord) { (record, error) in
                switch error {
                case let .some(error):
                    os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
                    completion(false)
                    return
                case .none: break
                }
                
                completion(true)
        }
    }

    func createNewGroup(sender: UIViewController) {
        let sharingController = UICloudSharingController { [weak self] (_, completion: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
            guard let self = self else { return }
            self.createNewGroup(completion: completion)
        }
        sharingController.availablePermissions = [.allowPrivate, .allowReadWrite]
        sharingController.delegate = self
        sender.present(sharingController, animated: true) {}
    }

    func viewParticipants(sender: UIViewController, share: CKShare) {
        let sharingController = UICloudSharingController(share: share, container: CKContainer.default())
        sender.present(sharingController, animated: true) {}
    }

    func fetchMyGroups(in zone: CKRecordZone) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: .group, predicate: predicate)

        CKContainer.default()
            .privateCloudDatabase
            .perform(query, inZoneWith: zone.zoneID) { groups, error in
                switch error {
                case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription); return
                case .none: break
                }

                guard let newGroups = groups else { return }
                let currentGroups = Current.cloudKitGroupsSubject.value ?? Set<CKRecord>()
                let allGroups = currentGroups.union(newGroups)
                Current.cloudKitGroupsSubject.send(allGroups)
            }
    }

    func findAllFriendsWithApp() {
        CKContainer.default()
            .discoverAllIdentities { identities, error in
                switch error {
                case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription); return
                case .none: break
                }

                Current.cloudKitFriendsSubject.send(identities)
            }
    }

    // MARK: - Private
    
    private func createSubscription() {
        let subscription = CKQuerySubscription(recordType: .message,
                                               predicate: NSPredicate(value: true),
                                               options: [.firesOnRecordCreation])
        
        let messageInfo = CKSubscription.NotificationInfo()
        messageInfo.alertLocalizationKey = "message_register_alerted"
        messageInfo.alertLocalizationArgs = ["title"]
        messageInfo.soundName = "default"
        messageInfo.desiredKeys = ["title"]
        
        subscription.notificationInfo = messageInfo
        
        CKContainer.default().sharedCloudDatabase.save(subscription) { (subscription, error) in
            switch error {
            case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription); return
            case .none: break
            }
            
            guard let subscriptionID = subscription?.subscriptionID else { return }
            UserDefaults.standard.setValue(subscriptionID,
                                           forKey: Current.k.messageSubscriptionID)
        }
    }
    
    private func fetchAllZones() {
        CKContainer.default().sharedCloudDatabase.fetchAllRecordZones { zones, error in
            switch error {
            case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription); return
            case .none: break
            }

            self.fetchMyGroups(in: self.sharedMessageZone)

            guard let zone = zones?.first else { return }
            self.fetchSharedGroups(in: zone)
        }
    }
    
    private func fetchSharedGroups(in zone: CKRecordZone) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: .group, predicate: predicate)

        CKContainer.default()
            .sharedCloudDatabase
            .perform(query, inZoneWith: zone.zoneID) { groups, error in
                switch error {
                case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription); return
                case .none: break
                }

                guard let newGroups = groups else { return }
                let currentGroups = Current.cloudKitGroupsSubject.value ?? Set<CKRecord>()
                let allGroups = currentGroups.union(newGroups)
                Current.cloudKitGroupsSubject.send(allGroups)
            }
    }
    
    private func fetchUserRecord(with recordID: CKRecord.ID) {
        CKContainer.default().privateCloudDatabase.fetch(withRecordID: recordID) { record, error in
            switch error {
            case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription); return
            case .none: break
            }

            guard let record = record,
                let recordData = try? CKRecord.archive(record: record) else {
                self.discoverUserIdentity(with: recordID)
                return
            }
            UserDefaults.standard.set(recordData, forKey: Current.k.userAccount)
            Current.cloudKitUserSubject.send(record)
        }
    }

    private func discoverUserIdentity(with recordId: CKRecord.ID) {
        CKContainer.default().discoverUserIdentity(withUserRecordID: recordId, completionHandler: { userID, error in
            switch error {
            case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
            case .none: break
            }

            guard let userID = userID else {
                os_log("Uninitialized user ID", log: .cloudKit, type: .error)
                return
            }
            self.createNewUser(from: userID)
        })
    }
    
    private func setupZones() {
        CKContainer.default().privateCloudDatabase.save(sharedMessageZone) { _, error in
            switch error {
            case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription); return
            case .none: break
            }
        }
    }

    private func createNewGroup(completion: @escaping (CKShare?, CKContainer?, Error?) -> Void) {
        let zoneID = CKRecordZone.ID(zoneName: "SharedZone", ownerName: CKRecordZone.ID.default.ownerName)
        let recordID = CKRecord.ID(recordName: "New Group", zoneID: zoneID)
        let groupRecord = CKRecord(recordType: .group, recordID: recordID)

        groupRecord[GroupKey.name.rawValue] = "" as CKRecordValue
        groupRecord[GroupKey.userCount.rawValue] = 1 as CKRecordValue

        let groupShareRecord = CKShare(rootRecord: groupRecord)
        let recordsToSave = [groupRecord, groupShareRecord]

        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: [])
        operation.perRecordCompletionBlock = { _, error in
            switch error {
            case let .some(error):
                os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
                return
            case .none:
                break
            }
        }

        operation.modifyRecordsCompletionBlock = { _, _, error in
            switch error {
            case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription); return
            case .none: completion(groupShareRecord, CKContainer.default(), nil)
            }
        }

        CKContainer.default().privateCloudDatabase.add(operation)
    }
}
