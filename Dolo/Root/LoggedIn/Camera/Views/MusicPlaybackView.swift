//
//  MusicPlaybackView.swift
//  Dolo
//
//  Created by Joe Blau on 2/4/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

final class MusicPlaybackView: UIVisualEffectView {

    private let intrinsicHeight: CGFloat
    
    init(height: CGFloat) {
        
        intrinsicHeight = height - 48.0

        super.init(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        translatesAutoresizingMaskIntoConstraints = false
        
        do {
            configureButtonTargets()
            configureViews()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Button Targets
    
    private func configureButtonTargets() {}

    // MARK: - Configure Views
    
    private func configureViews() {}
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIWindow().screen.bounds.width,
                      height: intrinsicHeight)
    }
    
    // MARK: - Actions
    
}
