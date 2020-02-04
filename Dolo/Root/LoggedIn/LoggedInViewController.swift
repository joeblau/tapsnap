//
//  LoggedInViewController.swift
//  Dolo
//
//  Created by Joe Blau on 1/31/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

class LoggedInViewController: UIViewController {

    weak var camera: CameraViewController? {
        return CameraViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Show onboarding
        
        // Show camera
        if let camera = camera {
            present(camera, animated: false) {}
        }
        // show settings
    }



}
