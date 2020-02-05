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

struct World {
    // Sensors
    let locationManager = CLLocationManager()
    let networkSession: URLSession = {
        let configuraiton = URLSessionConfiguration.background(withIdentifier: "tapsnap_url_session_config")
        configuraiton.allowsCellularAccess = true
        configuraiton.requestCachePolicy = .returnCacheDataElseLoad
        configuraiton.allowsExpensiveNetworkAccess = true
        
        return URLSession(configuration: configuraiton)
    }()
    
    // Constants
    let formatter = Formatter()
    
    // Reactive
    let recordingSubject = CurrentValueSubject<RecordAction, Never>(.stop)
    let editingSubject = CurrentValueSubject<EditState, Never>(.none)
    let activeCameraSubject = CurrentValueSubject<AVCaptureDevice.Position, Never>(.back)
    let presentViewContollersSubject = CurrentValueSubject<ShowViewController, Never>(.none)
    let mapDimensionSubject = CurrentValueSubject<MapDimension, Never>(.two)
    let mapAnnotationsSubject = CurrentValueSubject<AnnotationGroup, Never>(.them)
    let drawingColorSubject = CurrentValueSubject<UIColor, Never>(.white)
}

let Current = World()
