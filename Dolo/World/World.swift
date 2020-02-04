//
//  World.swift
//  Dolo
//
//  Created by Joe Blau on 2/2/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import Foundation
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
    case clear
}

enum ShowViewController {
    case none
    case playback
    case menu
    case search
}
struct World {
    let locationManager = CLLocationManager()
    let networkSession: URLSession = {
        let configuraiton = URLSessionConfiguration.background(withIdentifier: "tapsnap_url_session_config")
        configuraiton.allowsCellularAccess = true
        configuraiton.requestCachePolicy = .returnCacheDataElseLoad
        configuraiton.allowsExpensiveNetworkAccess = true
        
        return URLSession(configuration: configuraiton)
    }()
    
    let recordingSubject = CurrentValueSubject<RecordAction, Never>(.stop)
    let editingSubject = CurrentValueSubject<EditState, Never>(.none)
    let activeCameraSubject = CurrentValueSubject<AVCaptureDevice.Position, Never>(.back)
    let presentViewContollersSubject = CurrentValueSubject<ShowViewController, Never>(.none)
}

let Current = World()
