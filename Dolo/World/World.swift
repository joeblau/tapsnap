//
//  World.swift
//  Dolo
//
//  Created by Joe Blau on 2/2/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import Foundation
import Combine

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

struct World {
    let networkSession: URLSession = {
        let configuraiton = URLSessionConfiguration.background(withIdentifier: "tapsnap_url_session_config")
        configuraiton.allowsCellularAccess = true
        configuraiton.requestCachePolicy = .returnCacheDataElseLoad
        configuraiton.allowsExpensiveNetworkAccess = true
        
        return URLSession(configuration: configuraiton)
    }()
    
    let recordingSubject = CurrentValueSubject<RecordAction, Never>(.stop)
    let editingSubject = CurrentValueSubject<EditState, Never>(.none)

}

let Current = World()
