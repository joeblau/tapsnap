// AVAssetTrack+Extensions.swift
// Copyright (c) 2020 Tapsnap, LLC

import AVFoundation

extension AVAssetTrack {
    var size: CGSize {
        let size = naturalSize.applying(preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
}
