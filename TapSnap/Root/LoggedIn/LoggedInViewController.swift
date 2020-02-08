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
        let nc =  UINavigationController(rootViewController: CameraViewController())
        nc.modalPresentationStyle = .fullScreen
        nc.isToolbarHidden = false
        return nc
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        present(camera, animated: false) {}
    }
    
}
