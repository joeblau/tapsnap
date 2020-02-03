//
//  LoggedInViewController.swift
//  Dolo
//
//  Created by Joe Blau on 1/31/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

class LoggedInViewController: UIViewController {

    weak var playback: PlaybackViewController? {
        return PlaybackViewController()
    }
    weak var camera: CameraViewController? {
        return CameraViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        camera?.modalPresentationStyle = .overFullScreen
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Show onboarding
        
        // Show camera
        if let playback = playback {
            present(playback, animated: false) {
                // Log analytic event
            }
        }
        // show settings
        
    }


}
