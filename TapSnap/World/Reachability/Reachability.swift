//
//  Reachability.swift
//  Tapsnap
//
//  Created by Joe Blau on 5/9/20.
//

import SystemConfiguration
import Foundation
import Combine

enum ReachabilityType: Equatable {
    case wwan
    case wifi
}

enum ReachabilityStatus: Equatable {
    case offline
    case online(ReachabilityType)
    case unknown
}

extension Notification.Name {
    fileprivate static let ReachabilityStatusChanged = Notification.Name("ReachabilityStatusChanged")
}

class Reachability {
    fileprivate var reachabilityRef: SCNetworkReachability?
    fileprivate var cancellables = Set<AnyCancellable>()
    var reachabilitySubject = CurrentValueSubject<ReachabilityStatus, Never>(.unknown)
    
    init() {
        NotificationCenter.default
            .publisher(for: .ReachabilityStatusChanged)
            .compactMap { $0.userInfo?["status"] as? ReachabilityStatus }
            .removeDuplicates()
            .sink { self.reachabilitySubject.send($0) }
            .store(in: &cancellables)
        
        let host = "google.com"
        var context = SCNetworkReachabilityContext(version: 0,
                                                   info: nil,
                                                   retain: nil,
                                                   release: nil,
                                                   copyDescription: nil)
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, host) else {
            preconditionFailure("could not crate reachability with name")
        }
        
        SCNetworkReachabilitySetCallback(reachability, { (_, flags, _) in
            
            let status = ReachabilityStatus(reachabilityFlags: flags)
            NotificationCenter.default.post(name: .ReachabilityStatusChanged,
                                            object: nil,
                                            userInfo: ["status": status])
        }, &context)
        
        SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
    }
}

extension ReachabilityStatus {
    fileprivate init(reachabilityFlags flags: SCNetworkReachabilityFlags) {
        let connectionRequired = flags.contains(.connectionRequired)
        let isReachable = flags.contains(.reachable)
        let isWWAN = flags.contains(.isWWAN)
        
        guard !connectionRequired && isReachable else {
            self = .offline
            return
        }
        switch isWWAN {
        case true: self = .online(.wwan)
        case false: self = .online(.wifi)
        }
    }
}
