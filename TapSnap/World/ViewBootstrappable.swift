//
//  ViewControllerBootstrappable.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/7/20.
//

import Foundation

@objc protocol ViewBootstrappable {
    @objc optional func configureButtonTargets()
    @objc optional func configureViews()
    @objc optional func configureGestureRecoginzers()
    @objc optional func configureStreams()
}

extension ViewBootstrappable {
    func bootstrap() {
        configureButtonTargets?()
        configureStreams?()
        configureViews?()
        configureGestureRecoginzers?()
    }
}
