// CKContainer+User.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import Combine
import UIKit

extension CKContainer {
    func currentUser() {
        guard UserDefaults.standard.data(forKey: Current.k.userAccount) == nil else { return }
        fetchUserRecordID { [unowned self] recordID, error in
            guard self.no(error: error), let recordID = recordID else { return }

            let creatorReference = CKRecord.Reference(recordID: recordID, action: .none)
            let creatorPredicate = NSPredicate(format: "creator == %@", creatorReference)
            let recipientPredicate = NSPredicate(format: "recipient == %@", creatorReference)

            let creatorReferenceData = try? NSKeyedArchiver.archivedData(withRootObject: creatorReference, requiringSecureCoding: true)
            UserDefaults.standard.set(creatorReferenceData, forKey: Current.k.creatorReference)

            let creatorPredicateData = try? NSKeyedArchiver.archivedData(withRootObject: creatorPredicate, requiringSecureCoding: true)
            UserDefaults.standard.set(creatorPredicateData, forKey: Current.k.creatorPredicate)

            let recipientPredicateData = try? NSKeyedArchiver.archivedData(withRootObject: recipientPredicate, requiringSecureCoding: true)
            UserDefaults.standard.set(recipientPredicateData, forKey: Current.k.recipientPredicate)
            self.buildUser(with: recordID)
        }
    }

    func updateUser(image url: URL, completion: @escaping (Bool) -> Void) {
        guard let data = UserDefaults.standard.data(forKey: Current.k.userAccount),
            let userRecord = try? CKRecord.unarchive(data: data) else {
            completion(false); return
        }

        publicCloudDatabase.fetch(withRecordID: userRecord.recordID) { record, error in
            guard self.no(error: error), let userRecord = record else { completion(false); return }

            userRecord[UserAliasKey.avatar] = CKAsset(fileURL: url)

            self.publicCloudDatabase.save(userRecord) { record, error in
                guard self.no(error: error),
                    let record = record,
                    let data = try? CKRecord.archive(record: record) else { completion(false); return }

                UserDefaults.standard.set(data, forKey: Current.k.userAccount)
                Current.cloudKitUserSubject.send(record)

                completion(true)
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

    func fetchUser(with recordID: CKRecord.ID, completion: @escaping (_ username: String, _ avatar: UIImage?) -> Void) {
        publicCloudDatabase.fetch(withRecordID: recordID) { record, error in
            guard self.no(error: error), let userRecord = record else { return }

            let username = userRecord[UserAliasKey.name] as? String ?? "-"
            var image: UIImage?
            if let avatarAsset = userRecord[UserAliasKey.avatar] as? CKAsset,
                let avatarURL = avatarAsset.fileURL,
                let imageData = try? Data(contentsOf: avatarURL) {
                UserDefaults.standard.set(imageData, forKey: Current.k.currentUserAvatar)
                image = UIImage(data: imageData)
            }

            if let data = try? CKRecord.archive(record: userRecord) {
                UserDefaults.standard.set(data, forKey: Current.k.userAccount)
                Current.cloudKitUserSubject.send(userRecord)
            }
            completion(username, image)
        }
    }

    // MARK: - Private

    private func buildUser(with recordID: CKRecord.ID) {
        switch UserDefaults.standard.data(forKey: Current.k.userAccount) {
        case let .some(record):
            guard let user = try? CKRecord.unarchive(data: record) else { return }
            Current.cloudKitUserSubject.send(user)
        case .none:
            discoverUser(with: recordID)
        }
    }

    private func discoverUser(with recordID: CKRecord.ID) {
        discoverUserIdentity(withUserRecordID: recordID) { [unowned self] identity, error in
            guard self.no(error: error), let identity = identity else { return }
            self.createUser(from: identity)
        }
    }

    private func createUser(from identity: CKUserIdentity) {
        guard let components = identity.nameComponents,
            let creatorReferenceData = UserDefaults.standard.data(forKey: Current.k.creatorReference),
            let creatorReference = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(creatorReferenceData) as? CKRecord.Reference else {
            fatalError("No identity name components")
        }

        let name = Current.formatter.personName.string(from: components)
        let user = CKRecord(recordType: .userAlias)
        user[UserAliasKey.name] = name
        user[UserAliasKey.creator] = creatorReference

        publicCloudDatabase.save(user) { [unowned self] record, error in
            guard self.no(error: error),
                let record = record,
                let data = try? CKRecord.archive(record: record) else { return }

            UserDefaults.standard.set(name, forKey: Current.k.currentUserName)
            UserDefaults.standard.set(data, forKey: Current.k.userAccount)
            Current.cloudKitUserSubject.send(record)
        }
    }
}
