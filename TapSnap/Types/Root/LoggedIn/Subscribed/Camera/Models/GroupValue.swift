// GroupValue.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import UIKit

struct GroupValue: Hashable {
    let record: CKRecord?
    let identifier = UUID()

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: GroupValue, rhs: GroupValue) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
