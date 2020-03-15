// SubscriptionViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

class SubscriptionViewController: UIPageViewController {
    init() {
        super.init(transitionStyle: .scroll,
                   navigationOrientation: .horizontal,
                   options: nil)
//        delegate = self
//        let s = SubscriptionValueViewController(offerImage: UIImage(systemName: "creditcard")!,
//        offerTitle: "Great",
//        offerDescription: "Value")
//        s.view.backgroundColor = .red
//
//        addChild(s)
//
//        let t = SubscriptionValueViewController(offerImage: UIImage(systemName: "creditcard")!,
//        offerTitle: "Great",
//        offerDescription: "Value")
//        t.view.backgroundColor = .yellow
//        addChild(t)
//        addChild([

//        SubscriptionValueViewController(offerImage: UIImage(systemName: "")!,
//                                        offerTitle: "Great",
//                                        offerDescription: "Value") as! UIViewController
//    ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SubscriptionViewController: UIPageViewControllerDelegate {
    override func setViewControllers(_: [UIViewController]?,
                                     direction _: UIPageViewController.NavigationDirection,
                                     animated _: Bool,
                                     completion _: ((Bool) -> Void)? = nil) {
        delegate = self
        let s = SubscriptionValueViewController(offerImage: UIImage(systemName: "creditcard")!,
                                                offerTitle: "Great",
                                                offerDescription: "Value")

        addChild(s)

        let t = SubscriptionValueViewController(offerImage: UIImage(systemName: "creditcard")!,
                                                offerTitle: "Great",
                                                offerDescription: "Value")
        addChild(t)
    }
}
