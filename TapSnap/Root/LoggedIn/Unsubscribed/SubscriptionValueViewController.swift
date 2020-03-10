//
//  SubscriptionValueViewController.swift
//  Tapsnap
//
//  Created by Joe Blau on 3/7/20.
//

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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
