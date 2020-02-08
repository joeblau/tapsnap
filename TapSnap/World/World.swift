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

enum RecordAction {
    case start
    case stop
}

enum EditState {
    case none
    case keyboard
    case drawing
    case music
    case clear
}

enum ShowViewController {
    case none
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

struct World {
    // Sensors
    var locationManager = CLLocationManager()
    var networkSession: URLSession = {
        let configuraiton = URLSessionConfiguration.background(withIdentifier: "tapsnap_url_session_config")
        configuraiton.allowsCellularAccess = true
        configuraiton.requestCachePolicy = .returnCacheDataElseLoad
        configuraiton.allowsExpensiveNetworkAccess = true
        
        return URLSession(configuration: configuraiton)
    }()
    
    // Constants
    var formatter = Formatter()
    
    // Reactive
    var recordingSubject = CurrentValueSubject<RecordAction, Never>(.stop)
    var editingSubject = CurrentValueSubject<EditState, Never>(.none)
    var activeCameraSubject = CurrentValueSubject<AVCaptureDevice.Position, Never>(.back)
    var presentViewContollersSubject = CurrentValueSubject<ShowViewController, Never>(.none)
    var mapDimensionSubject = CurrentValueSubject<MapDimension, Never>(.two)
    var mapAnnotationsSubject = CurrentValueSubject<AnnotationGroup, Never>(.them)
    var drawingColorSubject = CurrentValueSubject<UIColor, Never>(.white)
    var topLeftNavBarSubject = CurrentValueSubject<LeftNavBarItem, Never>(.menu)
}

var Current = World()
