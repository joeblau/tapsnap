//
//  LoggedInViewController.swift
//  Dolo
//
//  Created by Joe Blau on 1/31/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

final class LoggedInViewController: UIViewController {

    private lazy var camera: UINavigationController = {
        return UINavigationController(rootViewController: CameraViewController())
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        camera.modalPresentationStyle = .fullScreen
        camera.isToolbarHidden = false
        present(camera, animated: false) {}
    }
    
}
