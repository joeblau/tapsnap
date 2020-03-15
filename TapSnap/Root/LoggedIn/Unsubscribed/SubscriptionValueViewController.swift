// SubscriptionValueViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

class SubscriptionValueViewController: UIViewController {
    private let offerImage: UIImage
    private let offerTitle: String
    private let offerDescription: String

    init(offerImage: UIImage,
         offerTitle: String,
         offerDescription: String) {
        self.offerImage = offerImage
        self.offerTitle = offerTitle
        self.offerDescription = offerDescription

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
