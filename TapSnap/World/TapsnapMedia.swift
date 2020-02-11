//
//  MetadataController.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/11/20.
//

import UIKit
import AVFoundation
import CoreLocation

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

