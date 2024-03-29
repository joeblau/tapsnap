// Formatter.swift
// Copyright (c) 2020 Tapsnap, LLC

import Contacts
import MapKit
import UIKit

struct Formatter {
    let distance: MKDistanceFormatter = {
        let f = MKDistanceFormatter()
        f.unitStyle = .abbreviated
        return f
    }()

    let timeAgo: RelativeDateTimeFormatter = {
        RelativeDateTimeFormatter()
    }()

    let progress: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.hour, .minute, .second]
        f.unitsStyle = .full
        return f
    }()

    let personName: PersonNameComponentsFormatter = {
        PersonNameComponentsFormatter()
    }()

    let dateTimeDigitized: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy:MM:dd HH:mm:ss"
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()
}

extension CNPostalAddress {
    var streetCity: String {
        "\(street.trimmingCharacters(in: CharacterSet.letters.inverted)), \(city)"
    }
}
