//
//  CloudKitManager.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/16/20.
//

import UIKit
import CloudKit
import os.log

class CloudKitManager: NSObject {
    
    func createNewGroup(sender: UIViewController) {
        let sharingController = UICloudSharingController { [weak self] (controller, completion: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
            guard let `self` = self else { return }
            self.createNewGroup(completion: completion)
        }
        sharingController.availablePermissions = [.allowPrivate, .allowReadWrite]
        sharingController.delegate = self
        sender.present(sharingController, animated: true) {}
    }

    // MARK: - Private
    
    private func createNewGroup(completion: @escaping (CKShare?, CKContainer?, Error?) -> Void) {
        let groupRecord = CKRecord(recordType: "Group")
        groupRecord["name"] = "New" as CKRecordValue

        let groupShareRecord = CKShare(rootRecord: groupRecord)
        let recordsToSave = [groupRecord, groupShareRecord]
        
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: [])
        operation.perRecordCompletionBlock = { (record, error) in
            switch error {
            case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
            case .none: break
            }
        }
        
        operation.modifyRecordsCompletionBlock = { (savedRecords, deletedRecordIDs, error) in
            switch error {
            case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
            case .none: completion(groupShareRecord, CKContainer.default(), nil)
            }
        }
        
        CKContainer.default().privateCloudDatabase.add(operation)
    }
}
