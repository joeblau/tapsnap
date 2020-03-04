//
//  UINavigationBar+Extensions.swift
//  Tapsnap
//
//  Created by Joe Blau on 3/3/20.
//

import UIKit

extension UINavigationBar {

    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }

        switch view.isKind(of: UIControl.self) {
        case true: return super.hitTest(point, with: event)
        case false: return nil
        }
    }
}
