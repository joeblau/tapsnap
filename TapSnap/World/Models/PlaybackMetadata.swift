//
//  PlaybackMetadata.swift
//  Tapsnap
//
//  Created by Joe Blau on 3/2/20.
//

import UIKit
import CoreLocation

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
