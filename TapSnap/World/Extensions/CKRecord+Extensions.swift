// CKRecord+Extensions.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit

extension CKRecord {
    subscript(key: UserKey) -> Any? {
        get { self[key.rawValue] }
        set { self[key.rawValue] = newValue as? CKRecordValue }
    }
    
    subscript(key: GroupKey) -> Any? {
        get { self[key.rawValue] }
        set { self[key.rawValue] = newValue as? CKRecordValue }
    }
    
    subscript(key: MessageKey) -> Any? {
        get { self[key.rawValue] }
        set { self[key.rawValue] = newValue as? CKRecordValue }
    }
    
    subscript(key: SigningKey) -> Any? {
        get { self[key.rawValue] }
        set { self[key.rawValue] = newValue as? CKRecordValue }
    }

    static func archive(record: CKRecord) throws -> Data {
        try NSKeyedArchiver.archivedData(withRootObject: record, requiringSecureCoding: true)
    }

    static func unarchive(data: Data) throws -> CKRecord? {
        try NSKeyedUnarchiver.unarchivedObject(ofClass: CKRecord.self, from: data)
    }
}

extension CKRecord.RecordType {
    static var message = "Message"
    static var group = "Group"
    static var user = "User"
    static var inbox = "Inbox"
    static var privateKey = "PrivateKey"
    static var publicKey = "PublicKey"
}
