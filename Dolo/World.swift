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

struct World {
    let recordingSubject = CurrentValueSubject<RecordAction, Never>(.stop)
}

let Current = World()
