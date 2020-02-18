//
//  SearchContactsValue.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/17/20.
//

import UIKit

struct SearchContactsValue: Hashable {
    let image: UIImage = UIImage(systemName: "person.crop.circle.fill",
                                 withConfiguration: UIImage.SymbolConfiguration(scale: .large))!
    let name: String
    let identifier = UUID()

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: SearchContactsValue, rhs: SearchContactsValue) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
