// LoggedInViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

final class LoggedInViewController: UIViewController {
    private lazy var camera: UINavigationController = {
        let nc = UINavigationController(rootViewController: CameraViewController())
        nc.modalPresentationStyle = .fullScreen
        nc.isToolbarHidden = false
        return nc
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        present(camera, animated: false) {}
    }
}
