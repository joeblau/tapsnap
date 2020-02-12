// TapsnapMedia.swift
// Copyright (c) 2020 Tapsnap, LLC

import AVFoundation
import CoreLocation
import UIKit

enum MediaType {
    case photo(URL)
    case movie(URL)
}

struct TapsnapMedia {
    var media: MediaType
    var user: String
    var timestamp: Date
    var group: String?
    var location: CLLocation?
    var address: String?
    var artwork: UIImage?
    var title: String?
    var artist: String?
    var songId: String?
}
