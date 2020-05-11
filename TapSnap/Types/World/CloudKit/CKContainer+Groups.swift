// CKContainer+Groups.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import UIKit

extension CKContainer {
    func createNewGroup(with name: String, from viewController: MyGroupsViewController) {
        let recordID = CKRecord.ID(recordName: UUID().uuidString, zoneID: sharedZoneID)
        let group = CKRecord(recordType: .group, recordID: recordID)

        group[GroupKey.name] = name
        group[GroupKey.userCount] = 1

        let share = CKShare(rootRecord: group)
        share.publicPermission = .readOnly

        let sharingController = UICloudSharingController(preparationHandler: { (_, handler:
            @escaping (CKShare?, CKContainer?, Error?) -> Void) in

            let operation = CKModifyRecordsOperation(recordsToSave: [group, share],
                                                     recordIDsToDelete: nil)
            operation.perRecordCompletionBlock = { [unowned self] _, error in
                guard self.no(error: error) else { return }
            }
            operation.modifyRecordsCompletionBlock = { _, _, error in
                handler(share, CKContainer.default(), error)
            }
            self.privateCloudDatabase.add(operation)
        })
        sharingController.availablePermissions = [.allowReadOnly]
        sharingController.delegate = viewController

        viewController.present(sharingController, animated: true, completion: nil)
    }

    func updateGroup(recordID: CKRecord.ID, image url: URL, completion: @escaping (Bool) -> Void) {
        privateCloudDatabase.fetch(withRecordID: recordID) { record, error in
            guard self.no(error: error), let groupRecord = record else { completion(false); return }

            groupRecord[GroupKey.avatar] = CKAsset(fileURL: url)

            self.privateCloudDatabase.save(groupRecord) { record, error in
                guard self.no(error: error), let _ = record else { completion(false); return }
                completion(true)
            }
        }
    }

    func updateGroup(recordID: CKRecord.ID, name: String, completion: @escaping (Bool) -> Void) {
        privateCloudDatabase.fetch(withRecordID: recordID) { record, error in
            guard self.no(error: error), let groupRecord = record else { completion(false); return }

            groupRecord[GroupKey.name] = name

            self.privateCloudDatabase.save(groupRecord) { record, error in
                guard self.no(error: error), let _ = record else { completion(false); return }
                completion(true)
            }
        }
    }

    func removeGroup(recordID: CKRecord.ID, completion: @escaping (Bool) -> Void) {
        privateCloudDatabase.delete(withRecordID: recordID) { _, error in
            guard self.no(error: error) else { completion(false); return }
            completion(true)
        }
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

            share[CKShare.SystemFieldKey.thumbnailImageData] = record[GroupKey.avatar] as? NSData ?? thumbnailData
            DispatchQueue.main.async {
                let controlloer = UICloudSharingController(share: share,
                                                           container: CKContainer.default())
                controlloer.availablePermissions = [.allowPublic, .allowReadOnly]
                sender.present(controlloer, animated: true, completion: nil)
            }
        }
    }

    func fetchAllGroups() {
        let query = CKQuery(recordType: .group, predicate: NSPredicate(value: true))
        Current.cloudKitGroupsSubject.send(Set<CKRecord>())

        sharedCloudDatabase.fetchAllRecordZones { [unowned self] zones, error in
            zones?.forEach { zone in
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
            guard self.no(error: error), let groups = records else {
                self.bootstrapSahredRecordZone()
                return
            }

            let exsitingGroups = Current.cloudKitGroupsSubject.value ?? Set<CKRecord>()
            let newGroups = Set(groups)
            let unionGroups = newGroups.union(exsitingGroups)
            Current.cloudKitGroupsSubject.send(unionGroups)
        }
    }

    private func bootstrapSahredRecordZone() {
        let sharedZone = CKRecordZone(zoneID: sharedZoneID)
        privateCloudDatabase.save(sharedZone) { _, error in
            guard self.no(error: error) else { return }
        }
    }
}
