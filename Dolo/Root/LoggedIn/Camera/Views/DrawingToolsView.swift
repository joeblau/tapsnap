//
//  DrawingToolsView.swift
//  Dolo
//
//  Created by Joe Blau on 2/2/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

class DrawingToolsView: UIVisualEffectView {

    let intrinsicHeight: CGFloat
    
    init(height: CGFloat) {
        intrinsicHeight = height - 48.0
        super.init(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIWindow().screen.bounds.width,
                      height: intrinsicHeight)
    }

}
