// ViewBootstrappable.swift
// Copyright (c) 2020 Tapsnap, LLC

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
