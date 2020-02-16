//
//  Data+Extensions.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/14/20.
//

import UIKit
import AVFoundation
import MediaPlayer

// MARK: - Photo

extension Data {
    func updateMetadata() -> Data? {
        guard let source = CGImageSourceCreateWithData(self as CFData, nil),
            let ref = CGImageSourceGetType(source),
            let copiedMetadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else { return nil }
        
        var metadata = copiedMetadata
        
        if let currentAddress = Current.currentAddressSubject.value {
            metadata[kCGImagePropertyExifDictionary as String] = [kCGImagePropertyExifCameraOwnerName: "",
                                                                  kCGImagePropertyExifUserComment: currentAddress]
        }
        
        if let currentLocation = Current.currentLocationSubject.value {
            metadata[kCGImagePropertyGPSDictionary as String] = [kCGImagePropertyGPSLatitudeRef: currentLocation.coordinate.latitude < 0 ? "S" : "N",
                                                                 kCGImagePropertyGPSLatitude: fabs(currentLocation.coordinate.latitude),
                                                                 kCGImagePropertyGPSLongitudeRef: currentLocation.coordinate.longitude < 0 ? "W" : "E",
                                                                 kCGImagePropertyGPSLongitude: fabs(currentLocation.coordinate.longitude),
                                                                 kCGImagePropertyGPSAltitudeRef: currentLocation.altitude < 0 ? 1 : 0,
                                                                 kCGImagePropertyGPSAltitude: fabs(currentLocation.altitude)]
        }
        
        let destinationData = NSMutableData(data: self)
        guard let destination = CGImageDestinationCreateWithData(destinationData, ref, 1, nil) else {
            return nil
        }
        
        CGImageDestinationAddImageFromSource(destination, source, 0, metadata as CFDictionary)
        if !CGImageDestinationFinalize(destination) {
            return nil
        }
        return destinationData as Data
    }
}

// MARK: - Movie

extension Array where Element: AVMetadataItem {
    static func movieMetadata() -> [AVMetadataItem] {
        timestamp.value = String(format: "%f", Date().timeIntervalSince1970) as NSString

        if let currentLocation = Current.currentLocationSubject.value {
            location.value = String(format: "%+09.5f%+010.5f%+.0fCRSWGS_84",
                                    currentLocation.coordinate.latitude,
                                    currentLocation.coordinate.longitude,
                                    currentLocation.altitude) as NSString
        }

        if let currentAddress = Current.currentAddressSubject.value {
            address.value = currentAddress as NSString
        }

        if let nowPlaying = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem,
            Current.musicSyncSubject.value {
            if let nowPlayingCoverArt = nowPlaying.artwork?.image(at: CGSize(width: 128, height: 128))?.pngData() {
                coverArt.value = nowPlayingCoverArt as NSData
            }

            if let nowPlayingTitle = nowPlaying.title as NSString? {
                title.value = nowPlayingTitle
            }
            if let nowPlayingArtist = nowPlaying.artist as NSString? {
                artist.value = nowPlayingArtist
            }

            songId.value = String(nowPlaying.playbackStoreID) as NSString
        }

        return [group, user, timestamp, location, address, coverArt, title, artist, songId]
    }
    
    private static var group: AVMutableMetadataItem {
        let i = AVMutableMetadataItem()
        i.keySpace = .quickTimeUserData
        i.key = AVMetadataKey.quickTimeUserDataKeyAlbum as NSString
        i.identifier = AVMetadataIdentifier.quickTimeUserDataAlbum
        return i
    }

    private static var user: AVMutableMetadataItem {
        let i = AVMutableMetadataItem()
        i.keySpace = .quickTimeUserData
        i.key = AVMetadataKey.quickTimeUserDataKeyArtist as NSString
        i.identifier = AVMetadataIdentifier.quickTimeUserDataArtist
        return i
    }

    private static var timestamp: AVMutableMetadataItem {
        let i = AVMutableMetadataItem()
        i.keySpace = .quickTimeUserData
        i.key = AVMetadataKey.quickTimeUserDataKeyCreationDate as NSString
        i.identifier = AVMetadataIdentifier.quickTimeUserDataCreationDate
        return i
    }

    private static var location: AVMutableMetadataItem {
        let i = AVMutableMetadataItem()
        i.keySpace = .quickTimeUserData
        i.key = AVMetadataKey.quickTimeUserDataKeyLocationISO6709 as NSString
        i.identifier = AVMetadataIdentifier.quickTimeUserDataLocationISO6709
        return i
    }

    private static var address: AVMutableMetadataItem {
        let i = AVMutableMetadataItem()
        i.keySpace = .quickTimeUserData
        i.key = AVMetadataKey.quickTimeUserDataKeyInformation as NSString
        i.identifier = AVMetadataIdentifier.quickTimeUserDataInformation
        return i
    }

    private static var coverArt: AVMutableMetadataItem {
        let i = AVMutableMetadataItem()
        i.keySpace = .iTunes
        i.key = AVMetadataKey.iTunesMetadataKeyCoverArt as NSString
        i.identifier = AVMetadataIdentifier.iTunesMetadataCoverArt
        return i
    }

    private static var title: AVMutableMetadataItem {
        let i = AVMutableMetadataItem()
        i.keySpace = .iTunes
        i.key = AVMetadataKey.iTunesMetadataKeySongName as NSString
        i.identifier = AVMetadataIdentifier.iTunesMetadataSongName
        return i
    }

    private static var artist: AVMutableMetadataItem {
        let i = AVMutableMetadataItem()
        i.keySpace = .iTunes
        i.key = AVMetadataKey.iTunesMetadataKeyArtist as NSString
        i.identifier = AVMetadataIdentifier.iTunesMetadataArtist
        return i
    }

    private static var songId: AVMutableMetadataItem {
        let i = AVMutableMetadataItem()
        i.keySpace = .iTunes
        i.key = AVMetadataKey.iTunesMetadataKeySongID as NSString
        i.identifier = AVMetadataIdentifier.iTunesMetadataSongID
        return i
    }
}
