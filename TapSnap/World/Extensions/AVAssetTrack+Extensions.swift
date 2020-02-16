//
//  AVAssetTrack+Extensions.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/15/20.
//

import AVFoundation

extension AVAssetTrack {
    var size: CGSize {
        let size = naturalSize.applying(preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
}
