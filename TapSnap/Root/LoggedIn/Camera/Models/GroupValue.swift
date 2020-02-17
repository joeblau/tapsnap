// GroupValue.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

struct GroupValue: Hashable {
    let image: UIImage = UIImage(systemName: "person.crop.circle.fill.badge.exclam")!
    let name: String
    let participantCount: Int = 0
    let identifier = UUID()

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: GroupValue, rhs: GroupValue) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
