// CloudKitManager.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import os.log
import UIKit

class CloudKitManager: NSObject {
    private let sharedMessageZone = CKRecordZone(zoneName: "SharedZone")

    override init() {
        super.init()
        setupZones()
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

    // MARK: - Private

    private func setupZones() {
        CKContainer.default().privateCloudDatabase.save(sharedMessageZone) { _, error in
            switch error {
            case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
            case .none: break
            }
        }
    }

    private func createNewGroup(completion: @escaping (CKShare?, CKContainer?, Error?) -> Void) {
        let zoneID = CKRecordZone.ID(zoneName: "SharedZone", ownerName: CKRecordZone.ID.default.ownerName)
        let recordID = CKRecord.ID(recordName: UUID().uuidString, zoneID: zoneID)
        let groupRecord = CKRecord(recordType: "Group", recordID: recordID)

        groupRecord["name"] = "New" as CKRecordValue
        groupRecord["users"] = 0 as CKRecordValue

        let groupShareRecord = CKShare(rootRecord: groupRecord)
        let recordsToSave = [groupRecord, groupShareRecord]

        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: [])
        operation.perRecordCompletionBlock = { _, error in
            switch error {
            case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
            case .none: break
            }
        }

        operation.modifyRecordsCompletionBlock = { _, _, error in
            switch error {
            case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
            case .none: completion(groupShareRecord, CKContainer.default(), nil)
            }
        }

        CKContainer.default().privateCloudDatabase.add(operation)
    }
}
