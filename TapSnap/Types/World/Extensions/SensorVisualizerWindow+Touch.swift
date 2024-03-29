// SensorVisualizerWindow+Touch.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

private protocol TouchVisualizable {
    func create(touch: UITouch)
    func move(touch: UITouch)
    func remove(touch: UITouch)
    func peek(touch: UITouch)
    func pop(touch: UITouch)
}

extension SensorVisualizerWindow: TouchVisualizable {
    public override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        event.allTouches?
            .forEach { touch in

                switch touch.phase {
                case .began: create(touch: touch)
                case .moved: move(touch: touch)
                case .ended, .cancelled, .stationary, .regionEntered, .regionExited, .regionMoved: remove(touch: touch)
                @unknown default: remove(touch: touch)
                }
            }
    }

    fileprivate func create(touch: UITouch) {
        guard let windowView = visualizationWindow.rootViewController?.view else { return }

        let touchView = UIView.buildTouchView(touchColor: primaryColor, borderColor: secondaryColor)
        touchView.center = touch.location(in: windowView)

        windowView.addSubview(touchView)
        touchPointViews[touch] = touchView
        touchView.layer.add(CAAnimationGroup.createTouchAnimation, forKey: "addTouch")
    }

    fileprivate func move(touch: UITouch) {
        guard let windowView = visualizationWindow.rootViewController?.view else { return }
        touchPointViews[touch]?.center = touch.location(in: windowView)
    }

    fileprivate func remove(touch: UITouch) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.touchPointViews
                .removeValue(forKey: touch)?
                .removeFromSuperview()
        }
        touchPointViews[touch]?.layer.add(CAAnimationGroup.removeTouchAnimation, forKey: "removeTouch")
        CATransaction.commit()
    }

    fileprivate func peek(touch: UITouch) {
        touchPointViews[touch]?.layer.removeAnimation(forKey: "addTouch")
        if touchPointViews[touch]?.layer.animationKeys()?.contains("peekTouch") ?? false {
            return
        }
        touchPointViews[touch]?.layer.add(CAAnimationGroup.peekTouchAnimation, forKey: "peekTouch")
    }

    fileprivate func pop(touch: UITouch) {
        touchPointViews[touch]?.layer.removeAnimation(forKey: "peekTouch")
        if touchPointViews[touch]?.layer.animationKeys()?.contains("popTouch") ?? false {
            return
        }
        touchPointViews[touch]?.layer.add(CAAnimationGroup.popTouchAnimation, forKey: "popTouch")
    }
}
