//
//  IndeterminateProgressView.swift
//  Dolo
//
//  Created by Joe Blau on 2/5/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

public typealias IndeterminateCompletionHandler = () -> ()

class IndeterminateProgressView: UIView {
    
    open var isAnimating: Bool {
        get {
            return bit.layer.animation(forKey: bitAnimationKey) != nil
        }
        set {
            switch newValue {
            case  true:  startAnimating()
            case false: stopAnimating(withExitTransition: false, completion: nil)
            }
        }
    }
    
    private lazy var bit: UIView = {
        let view = UIView()
        view.backgroundColor = .label
        self.addSubview(view)
        return view
    }()
    
    private let bitAnimationKey = "bitAnimationKey"
    private let bitAnimationduration: TimeInterval = 0.7
    private let bitExitTransitionKey = "bitExitTransitionKey"
    private let bitExitTransitionDuration: TimeInterval = 0.3
    private let bitExpandedWidth: CGFloat = 128
    private let bitHeight: CGFloat = 4
    private var bitContractedWidth: CGFloat { bitHeight }
    private var leftScreenEdgePosition: CGFloat { bitContractedWidth / 2.0 }
    private var rightScreenEdgePosition: CGFloat { UIScreen.main.bounds.width - bitContractedWidth / 2.0 }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        bit.layer.bounds.size = CGSize(width: bitContractedWidth, height: bitHeight)
        resetBitPosition()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func resetBitPosition() {
        bit.layer.position.x = bitContractedWidth / 2.0
        bit.layer.position.y = max(bitHeight / 2.0, bounds.size.height / 2.0)
    }
    
    open func startAnimating() {
        layoutIfNeeded()
        
        CATransaction.begin()
        
        let moveLeftAndRight = CABasicAnimation(keyPath: "position.x")
        moveLeftAndRight.fromValue = leftScreenEdgePosition
        moveLeftAndRight.toValue = rightScreenEdgePosition
        moveLeftAndRight.timingFunction = CAMediaTimingFunction(controlPoints: 0.65, 0, 0.35, 1)
        
        let expandAndContract = CAKeyframeAnimation(keyPath: "bounds.size.width")
        expandAndContract.values = [bitContractedWidth, bitExpandedWidth, bitContractedWidth]
        expandAndContract.keyTimes = [0, 0.5, 1]
        expandAndContract.timingFunctions = [
            CAMediaTimingFunction(controlPoints: 0.8, 0, 0.7, 1),
            CAMediaTimingFunction(controlPoints: 0.3, 0, 0.2, 1)
        ]
        
        let group = CAAnimationGroup()
        group.duration = bitAnimationduration
        group.autoreverses = true
        group.repeatCount = Float.infinity
        group.animations = [moveLeftAndRight, expandAndContract]
        group.isRemovedOnCompletion = false
        
        bit.layer.opacity = 1
        bit.layer.removeAnimation(forKey: bitExitTransitionKey)
        bit.layer.add(group, forKey: bitAnimationKey)
        
        CATransaction.commit()
    }
    
    open func stopAnimating(withExitTransition shouldTransition: Bool, completion: IndeterminateCompletionHandler?) {
        switch shouldTransition {
        case true:
            performExitTransition(withCompletion: completion)
        case false:
            bit.layer.removeAnimation(forKey: bitAnimationKey)
            completion?()
        }
    }
    
    private func performExitTransition(withCompletion completion: IndeterminateCompletionHandler?) {
        guard isAnimating, let presentationLayer = bit.layer.presentation() else {
            completion?()
            return
        }
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        let moveToCenter = CABasicAnimation(keyPath: "position.x")
        moveToCenter.fromValue = presentationLayer.position.x
        moveToCenter.toValue = Float(UIScreen.main.bounds.width / 2.0)
        
        let expandToFullWidth = CABasicAnimation(keyPath: "bounds.size.width")
        expandToFullWidth.fromValue = presentationLayer.bounds.size.width
        expandToFullWidth.toValue = Float(UIScreen.main.bounds.width)
        
        let fadeOut = CABasicAnimation(keyPath: "opacity")
        fadeOut.fromValue = 1
        fadeOut.toValue = 0
        
        let group = CAAnimationGroup()
        group.duration = bitExitTransitionDuration
        group.animations = [moveToCenter, expandToFullWidth, fadeOut]
        group.timingFunction = CAMediaTimingFunction(controlPoints: 0.1, 0.7, 0.25, 1)
        
        bit.layer.removeAnimation(forKey: bitAnimationKey)
        bit.layer.add(group, forKey: bitExitTransitionKey)
        bit.layer.opacity = 0
        
        CATransaction.commit()
    }

}
