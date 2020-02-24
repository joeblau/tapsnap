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

    func createNewUser(from identity: CKUserIdentity) {
        guard let identityComponents = identity.nameComponents else { return }

        let name = Current.formatter.personName.string(from: identityComponents)

        let userRecord = CKRecord(recordType: "User")
        userRecord[UserKey.name] = name

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

    func fetchAllZones() {
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

    func fetchMyGroups(in zone: CKRecordZone) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Group", predicate: predicate)

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

    func fetchSharedGroups(in zone: CKRecordZone) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Group", predicate: predicate)

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
    
    func postMessageToGroup() {
        CKContainer.default().sharedCloudDatabase
    }

    // MARK: - Private

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
        let groupRecord = CKRecord(recordType: "Group", recordID: recordID)

        groupRecord["name"] = "" as CKRecordValue
        groupRecord["users"] = 1 as CKRecordValue

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
