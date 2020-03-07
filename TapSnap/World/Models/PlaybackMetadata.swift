// PlaybackMetadata.swift
// Copyright (c) 2020 Tapsnap, LLC

import CoreLocation
import UIKit

struct PlaybackMetadata {
    var group: String
    var author: String
    var thumbnail: UIImage
    var date: Date
    var location: CLLocation?
    var address: String?
    var coverArt: UIImage?
    var title: String?
    var artist: String?
    var songId: String?
}
