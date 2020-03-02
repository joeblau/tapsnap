// World.swift
// Copyright (c) 2020 Tapsnap, LLC

import AVFoundation
import CloudKit
import Combine
import Contacts
import CoreLocation
import MapKit
import PencilKit
import UIKit

enum EditState {
    case none
    case keyboard
    case drawing
    case music
    case clear
}

enum ShowViewController {
    case none
    case camera
    case playback
    case menu
    case search
}

enum MapDimension {
    case two
    case three
}

enum AnnotationGroup {
    case them
    case all
}

enum LeftNavBarItem {
    case none
    case menu
    case clear
}

enum MediaAction {
    case none
    case capturePhoto
    case captureVideoStart
    case captureVideoEnd
}

enum MediaCapture {
    case photo(URL)
    case movie(URL)
}

enum MediaType {
    case photo
    case movie
}

struct World {
    let pki = PublicKeyCryptography()
    let k = Constants()

    // Sensors
    var locationManager: CLLocationManager = {
        let m = CLLocationManager()
        m.desiredAccuracy = kCLLocationAccuracyKilometer
        return m
    }()

    var geocoding = CLGeocoder()

    // Networking
    var networkSession: URLSession = {
        let configuraiton = URLSessionConfiguration.background(withIdentifier: "tapsnap_url_session_config")
        configuraiton.allowsCellularAccess = true
        configuraiton.requestCachePolicy = .returnCacheDataElseLoad
        configuraiton.allowsExpensiveNetworkAccess = true

        return URLSession(configuration: configuraiton)
    }()

    let mapView: MKMapView = {
        let mv = MKMapView()
        mv.translatesAutoresizingMaskIntoConstraints = false
        mv.isZoomEnabled = false
        mv.isScrollEnabled = false
        mv.isRotateEnabled = false
        mv.isPitchEnabled = false
        mv.showsCompass = false
        mv.showsScale = false
        mv.showsBuildings = true
        return mv
    }()

    // Constants
    var formatter = Formatter()

    // Reactive
    var editingSubject = CurrentValueSubject<EditState, Never>(.none)
    var activeCameraSubject = CurrentValueSubject<AVCaptureDevice.Position, Never>(.back)
    var presentViewContollersSubject = CurrentValueSubject<ShowViewController, Never>(.none)
    var mapDimensionSubject = CurrentValueSubject<MapDimension, Never>(.two)
    var mapAnnotationsSubject = CurrentValueSubject<AnnotationGroup, Never>(.them)
    var drawingColorSubject = CurrentValueSubject<UIColor, Never>(.white)
    var topLeftNavBarSubject = CurrentValueSubject<LeftNavBarItem, Never>(.menu)
    var mediaActionSubject = CurrentValueSubject<MediaAction, Never>(.none)
    var zoomVeloictySubject = CurrentValueSubject<CGPoint, Never>(.zero)

    var currentLocationSubject = CurrentValueSubject<CLLocation?, Never>(nil)
    var currentAddressSubject = CurrentValueSubject<String?, Never>(nil)
    var currentWatermarkSubject = CurrentValueSubject<UIImage?, Never>(nil)

    var musicSyncSubject = CurrentValueSubject<Bool, Never>(false)
    var lockMeidaBetweenSendSubject = CurrentValueSubject<Bool, Never>(false)

    var inboxURLsSubject = CurrentValueSubject<[URL]?, Never>(nil)
    
    // CloudKit
    var cloudKitUserSubject = CurrentValueSubject<CKRecord?, Never>(nil)
    var cloudKitGroupsSubject = CurrentValueSubject<Set<CKRecord>?, Never>(nil)
    var cloudKitFriendsSubject = CurrentValueSubject<[CKUserIdentity]?, Never>(nil)
    var cloudKitSelectedGroupSubject = CurrentValueSubject<CKRecord?, Never>(nil)
}

var Current = World()
