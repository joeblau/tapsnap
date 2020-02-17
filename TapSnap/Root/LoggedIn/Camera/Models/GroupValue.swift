//
//  GroupValue.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/16/20.
//

import UIKit

struct GroupValue: Hashable {
    let image: UIImage = UIImage(systemName: "person.crop.circle.fill.badge.exclam")!
    let name: String
    let participantCount: Int = 0
    let identifier = UUID()

    func hash(into hasher: inout Hasher)  {
        hasher.combine(identifier)
    }

    static func == (lhs: GroupValue, rhs: GroupValue) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
