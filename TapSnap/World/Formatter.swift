//
//  Formatter.swift
//  Dolo
//
//  Created by Joe Blau on 2/4/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit
import MapKit
import Contacts

struct Formatter {
    let distance: MKDistanceFormatter = {
        let f = MKDistanceFormatter()
        f.unitStyle = .abbreviated
        return f
    }()
    
    let timeAgo: RelativeDateTimeFormatter = {
       let f = RelativeDateTimeFormatter()
        return f
    }()
    
    let progress: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.hour, .minute, .second]
        f.unitsStyle = .full
        return f
    }()
}

extension CNPostalAddress {
    var streetCity: String {
        return "\(street.trimmingCharacters(in: CharacterSet.letters.inverted)), \(city)"
    }
}
