//
//  LoggedInViewController.swift
//  Dolo
//
//  Created by Joe Blau on 1/31/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

class LoggedInViewController: UIViewController {

    weak var camera: UINavigationController? {
        return UINavigationController(rootViewController: CameraViewController())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Show onboarding
        
        // Show camera
        if let camera = camera {
            camera.modalPresentationStyle = .fullScreen
            present(camera, animated: false) {}
        }
        // show settings
    }



}
