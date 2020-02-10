//
//  World.swift
//  Dolo
//
//  Created by Joe Blau on 2/2/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit
import Combine
import CoreLocation
import AVFoundation
import MapKit
import Contacts

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

struct World {
    // DELTE
    let fakeContact: CNMutablePostalAddress = {
        let pa = CNMutablePostalAddress()
        pa.street = "1884 Wood Acres Lane"
        pa.city = "Marieta"
        pa.state = "Georga"
        pa.postalCode = "30062"
        pa.country = "United States"
        return pa
    }()
    // Sensors
    var locationManager = CLLocationManager()
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
    var musicSyncSubject = CurrentValueSubject<Bool, Never>(false)
}

var Current = World()
