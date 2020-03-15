// EXIFData+Extensions.swift
// Copyright (c) 2020 Tapsnap, LLC

import AVFoundation
import CloudKit
import CoreLocation
import MediaPlayer
import UIKit

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
            exif[kCGImagePropertyExifCameraOwnerName as String] = userRecord[UserAliasKey.name] as? String ?? "-"
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

        var author: String?
        var address: String?
        var date = Date()
        if let exif = metadata[kCGImagePropertyExifDictionary as String] as? [String: Any] {
            author = exif[kCGImagePropertyExifCameraOwnerName as String] as? String
            address = exif[kCGImagePropertyExifUserComment as String] as? String

            if let dateTimeDigitized = exif[kCGImagePropertyExifDateTimeDigitized as String] as? String,
                let creationDate = Current.formatter.dateTimeDigitized.date(from: dateTimeDigitized) {
                date = creationDate
            }
        }

        var location: CLLocation?
        if let gps = metadata[kCGImagePropertyGPSDictionary as String] as? [String: Any],
            let latitude = gps[kCGImagePropertyGPSLatitude as String] as? Double,
            let latitudeRef = gps[kCGImagePropertyGPSLatitudeRef as String] as? String,
            let longitude = gps[kCGImagePropertyGPSLongitude as String] as? Double,
            let longitudeRef = gps[kCGImagePropertyGPSLongitudeRef as String] as? String {
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
    var playbackMetadta: PlaybackMetadata? {
        let group = AVMetadataItem.metadataItems(from: self, filteredByIdentifier: .quickTimeUserDataAlbum).first?.value as? String ?? "-"
        let author = AVMetadataItem.metadataItems(from: self, filteredByIdentifier: .quickTimeUserDataArtist).first?.value as? String ?? "-"
        let date: Date
        switch AVMetadataItem.metadataItems(from: self, filteredByIdentifier: .quickTimeUserDataCreationDate).first?.value as? String {
        case let .some(dateString):
            date = Date(timeIntervalSince1970: TimeInterval(dateString) ?? TimeInterval())
        case .none:
            date = Date()
        }
        let location: CLLocation?
        switch AVMetadataItem.metadataItems(from: self, filteredByIdentifier: .quickTimeUserDataLocationISO6709).first?.value as? String {
        case let .some(locationString):
            let stringSplit = locationString.split(separator: ",")
            if stringSplit.count == 4,
                let lat = Double(String(stringSplit[0])),
                let lon = Double(String(stringSplit[1])) {
                location = CLLocation(latitude: lat, longitude: lon)
            } else {
                location = nil
            }
        case .none:
            location = nil
        }

        let address = AVMetadataItem.metadataItems(from: self, filteredByIdentifier: .quickTimeUserDataInformation).first?.value as? String

        var coverArt: UIImage?
        if let coverArtData = AVMetadataItem.metadataItems(from: self, filteredByIdentifier: .iTunesMetadataCoverArt).first?.value as? Data,
            let coverArtImage = UIImage(data: coverArtData) {
            coverArt = coverArtImage
        }

        let title = AVMetadataItem.metadataItems(from: self, filteredByIdentifier: .iTunesMetadataSongName).first?.value as? String
        let artist = AVMetadataItem.metadataItems(from: self, filteredByIdentifier: .iTunesMetadataArtist).first?.value as? String
        let songId = AVMetadataItem.metadataItems(from: self, filteredByIdentifier: .iTunesMetadataSongID).first?.value as? String

        return PlaybackMetadata(group: group,
                                author: author,
                                thumbnail: UIImage(),
                                date: date,
                                location: location,
                                address: address,
                                coverArt: coverArt,
                                title: title,
                                artist: artist,
                                songId: songId)
    }

    static func movieMetadata(group name: String?) -> [AVMetadataItem] {
        var metadata = [AVMetadataItem]()

        if let groupName = name {
            let group = AVMutableMetadataItem()
            group.keySpace = .quickTimeUserData
            group.key = AVMetadataKey.quickTimeUserDataKeyAlbum as NSString
            group.identifier = AVMetadataIdentifier.quickTimeUserDataAlbum
            group.value = groupName as NSString
            metadata.append(group)
        }

        if let nameData = UserDefaults.standard.data(forKey: Current.k.userAccount),
            let userRecord = try? CKRecord.unarchive(data: nameData) {
            let author = AVMutableMetadataItem()
            author.keySpace = .quickTimeUserData
            author.key = AVMetadataKey.quickTimeUserDataKeyArtist as NSString
            author.identifier = AVMetadataIdentifier.quickTimeUserDataArtist
            author.value = userRecord[UserAliasKey.name] as? NSString ?? "-"
            metadata.append(author)
        }

        let timestamp = AVMutableMetadataItem()
        timestamp.keySpace = .quickTimeUserData
        timestamp.key = AVMetadataKey.quickTimeUserDataKeyCreationDate as NSString
        timestamp.identifier = AVMetadataIdentifier.quickTimeUserDataCreationDate
        timestamp.value = String(format: "%f", Date().timeIntervalSince1970) as NSString
        metadata.append(timestamp)

        if let currentLocation = Current.currentLocationSubject.value {
            let location = AVMutableMetadataItem()
            location.keySpace = .quickTimeUserData
            location.key = AVMetadataKey.quickTimeUserDataKeyLocationISO6709 as NSString
            location.identifier = AVMetadataIdentifier.quickTimeUserDataLocationISO6709
            location.value = String(format: "%+09.5f,%+010.5f,%+.0f,CRSWGS_84",
                                    currentLocation.coordinate.latitude,
                                    currentLocation.coordinate.longitude,
                                    currentLocation.altitude) as NSString
            metadata.append(location)
        }

        if let currentAddress = Current.currentAddressSubject.value {
            let address = AVMutableMetadataItem()
            address.keySpace = .quickTimeUserData
            address.key = AVMetadataKey.quickTimeUserDataKeyInformation as NSString
            address.identifier = AVMetadataIdentifier.quickTimeUserDataInformation
            address.value = currentAddress as NSString
            metadata.append(address)
        }

        if let nowPlaying = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem,
            Current.musicSyncSubject.value {
            if let nowPlayingCoverArt = nowPlaying.artwork?.image(at: CGSize(width: 128, height: 128))?.pngData() {
                let coverArt = AVMutableMetadataItem()
                coverArt.keySpace = .iTunes
                coverArt.key = AVMetadataKey.iTunesMetadataKeyCoverArt as NSString
                coverArt.identifier = AVMetadataIdentifier.iTunesMetadataCoverArt
                coverArt.value = nowPlayingCoverArt as NSData
                metadata.append(coverArt)
            }

            if let nowPlayingTitle = nowPlaying.title as NSString? {
                let title = AVMutableMetadataItem()
                title.keySpace = .iTunes
                title.key = AVMetadataKey.iTunesMetadataKeySongName as NSString
                title.identifier = AVMetadataIdentifier.iTunesMetadataSongName
                title.value = nowPlayingTitle
                metadata.append(title)
            }

            if let nowPlayingArtist = nowPlaying.artist as NSString? {
                let artist = AVMutableMetadataItem()
                artist.keySpace = .iTunes
                artist.key = AVMetadataKey.iTunesMetadataKeyArtist as NSString
                artist.identifier = AVMetadataIdentifier.iTunesMetadataArtist
                artist.value = nowPlayingArtist
                metadata.append(artist)
            }

            let songId = AVMutableMetadataItem()
            songId.keySpace = .iTunes
            songId.key = AVMetadataKey.iTunesMetadataKeySongID as NSString
            songId.identifier = AVMetadataIdentifier.iTunesMetadataSongID
            songId.value = String(nowPlaying.playbackStoreID) as NSString
            metadata.append(songId)
        }

        return metadata
    }
}
