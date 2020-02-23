//
//  CKRecord+Extensions.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/20/20.
//

import CloudKit

extension CKRecord {
    
    subscript(key: UserKey) -> Any? {
        get {
            return self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue as? CKRecordValue
        }
    }
    
    
    
    
}
