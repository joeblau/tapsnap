//
//  LoggedInViewController.swift
//  Dolo
//
//  Created by Joe Blau on 1/31/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

class LoggedInViewController: UIViewController {

    let camera = CameraViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        camera.modalPresentationStyle = .overFullScreen
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Show onboarding
        
        // Show camera
        present(camera, animated: false) {
            // Log analytic event
        }
        // show settings
        
    }


}
