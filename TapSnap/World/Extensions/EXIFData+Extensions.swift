// EXIFData+Extensions.swift
// Copyright (c) 2020 Tapsnap, LLC

import AVFoundation
import MediaPlayer
import UIKit
import CoreLocation
import CloudKit

// MARK: - Photo

extension Data {
    var updateMetadata: Data? {
        guard let source = CGImageSourceCreateWithData(self as CFData, nil),
            let ref = CGImageSourceGetType(source),
            let copiedMetadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else { return nil }
        
        var metadata = copiedMetadata
        
        var exif = [String: Any]()
        if let nameData = UserDefaults.standard.data(forKey: Current.k.userAccount),
            let userRecord = try? CKRecord.unarchive(data: nameData) {
            exif[kCGImagePropertyExifCameraOwnerName as String] = userRecord[UserKey.name] as? String ?? "-"
        }
        if let currentAddress = Current.currentAddressSubject.value {
            exif[kCGImagePropertyExifUserComment as String] = currentAddress
        }
        exif[kCGImagePropertyExifDateTimeDigitized as String] = Current.formatter.dateTimeDigitized.string(from: Date())
        
        metadata[kCGImagePropertyExifDictionary as String] = exif
        
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
    
    var playbackMetadata: PlaybackMetadata? {
        guard let source = CGImageSourceCreateWithData(self as CFData, nil),
            let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else { return nil }
        
        var author: String? = nil
        var address: String? = nil
        var date = Date()
        if let exif = metadata[kCGImagePropertyExifDictionary as String] as? [String: Any] {
            
            author = exif[kCGImagePropertyExifCameraOwnerName as String] as? String
            address = exif[kCGImagePropertyExifUserComment as String] as? String
            
            
            if let dateTimeDigitized = exif[kCGImagePropertyExifDateTimeDigitized as String] as? String,
                let creationDate = Current.formatter.dateTimeDigitized.date(from: dateTimeDigitized) {
                date = creationDate
            }
        }
        
        var location: CLLocation? = nil
        if let gps = metadata[kCGImagePropertyGPSDictionary as String] as? [String: Any],
            let latitude = gps[kCGImagePropertyGPSLatitude as String] as? Double,
            let latitudeRef = gps[kCGImagePropertyGPSLatitudeRef as String] as? String,
            let longitude = gps[kCGImagePropertyGPSLongitude as String] as? Double,
            let longitudeRef = gps[kCGImagePropertyGPSLongitudeRef as String] as? String  {
            
            let lat = latitudeRef == "S" ? latitude * -1 : latitude
            let lon = longitudeRef == "W" ? longitude * -1 : longitude
            
            location = CLLocation(latitude: lat, longitude: lon)
        }
        
        return PlaybackMetadata(group: "",
                                author: author ?? "-",
                                thumbnail: UIImage(),
                                date: date,
                                location: location,
                                address: address,
                                coverArt: nil,
                                title: nil,
                                artist: nil,
                                songId: nil)
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
