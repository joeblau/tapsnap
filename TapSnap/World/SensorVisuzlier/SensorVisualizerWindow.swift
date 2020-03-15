// SensorVisualizerWindow.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

public class SensorVisualizerWindow: UIWindow {
    let primaryColor: UIColor
    let secondaryColor: UIColor
    var animator: UIDynamicAnimator?

    var touchPointViews = [UITouch: UIView]()

    internal let visualizationWindow: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.isUserInteractionEnabled = false
        window.windowLevel = UIWindow.Level.statusBar
        window.backgroundColor = .clear
        window.isHidden = false
        window.rootViewController = UIViewController()
        window.rootViewController?.view.frame = UIScreen.main.bounds
        return window
    }()

    /// Initialize a sensor visualizer window
    ///
    /// - Parameters:
    ///     - frame: The size of the window which is usually the screen bounds
    ///     - primary (optional): The tap and shake color which defaults to the tint color
    ///     - secondary (optional): The tap border color which defaults to the tint color
    public init(frame: CGRect,
                primary: UIColor = UIView().tintColor,
                secondary: UIColor = UIView().tintColor) {
        primaryColor = primary
        secondaryColor = secondary

        super.init(frame: frame)
        if let windowView = visualizationWindow.rootViewController?.view {
            animator = UIDynamicAnimator(referenceView: windowView)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
