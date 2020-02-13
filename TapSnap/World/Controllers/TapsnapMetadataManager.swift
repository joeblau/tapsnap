// TapsnapMetadata.swift
// Copyright (c) 2020 Tapsnap, LLC

import AVFoundation
import MediaPlayer
import UIKit

class TapsnapMetadataManager {
    private var group: AVMutableMetadataItem = {
        let i = AVMutableMetadataItem()
        i.keySpace = .quickTimeUserData
        i.key = AVMetadataKey.quickTimeUserDataKeyAlbum as NSString
        i.identifier = AVMetadataIdentifier.quickTimeUserDataAlbum
        return i
    }()

    private var user: AVMutableMetadataItem = {
        let i = AVMutableMetadataItem()
        i.keySpace = .quickTimeUserData
        i.key = AVMetadataKey.quickTimeUserDataKeyArtist as NSString
        i.identifier = AVMetadataIdentifier.quickTimeUserDataArtist
        return i
    }()

    private var timestamp: AVMutableMetadataItem = {
        let i = AVMutableMetadataItem()
        i.keySpace = .quickTimeUserData
        i.key = AVMetadataKey.quickTimeUserDataKeyCreationDate as NSString
        i.identifier = AVMetadataIdentifier.quickTimeUserDataCreationDate
        return i
    }()

    private var location: AVMutableMetadataItem = {
        let i = AVMutableMetadataItem()
        i.keySpace = .quickTimeUserData
        i.key = AVMetadataKey.quickTimeUserDataKeyLocationISO6709 as NSString
        i.identifier = AVMetadataIdentifier.quickTimeUserDataLocationISO6709
        return i
    }()

    private var address: AVMutableMetadataItem = {
        let i = AVMutableMetadataItem()
        i.keySpace = .quickTimeUserData
        i.key = AVMetadataKey.quickTimeUserDataKeyInformation as NSString
        i.identifier = AVMetadataIdentifier.quickTimeUserDataInformation
        return i
    }()

    private var coverArt: AVMutableMetadataItem = {
        let i = AVMutableMetadataItem()
        i.keySpace = .iTunes
        i.key = AVMetadataKey.iTunesMetadataKeyCoverArt as NSString
        i.identifier = AVMetadataIdentifier.iTunesMetadataCoverArt
        return i
    }()

    private var title: AVMutableMetadataItem = {
        let i = AVMutableMetadataItem()
        i.keySpace = .iTunes
        i.key = AVMetadataKey.iTunesMetadataKeySongName as NSString
        i.identifier = AVMetadataIdentifier.iTunesMetadataSongName
        return i
    }()

    private var artist: AVMutableMetadataItem = {
        let i = AVMutableMetadataItem()
        i.keySpace = .iTunes
        i.key = AVMetadataKey.iTunesMetadataKeyArtist as NSString
        i.identifier = AVMetadataIdentifier.iTunesMetadataArtist
        return i
    }()

    private var songId: AVMutableMetadataItem = {
        let i = AVMutableMetadataItem()
        i.keySpace = .iTunes
        i.key = AVMetadataKey.iTunesMetadataKeySongID as NSString
        i.identifier = AVMetadataIdentifier.iTunesMetadataSongID
        return i
    }()

    func currentMetadata(for mediaAction: MediaAction) -> [AVMetadataItem] {
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
            Current.musicSyncSubject.value,
            mediaAction == .captureVideoStart {
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
}
