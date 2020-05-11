// LoggedInViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import CoreLocation
import os.log
import UIKit

final class LoggedInViewController: UIViewController {
    lazy var tag: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .tertiarySystemBackground
        l.text = self.title
        return l
    }()

    private lazy var camera: UINavigationController = {
        let nc = UINavigationController(rootViewController: CameraViewController())
        nc.modalPresentationStyle = .fullScreen
        nc.isToolbarHidden = false
        return nc
    }()

    private lazy var subscription: UINavigationController = {
        let nc = UINavigationController(rootViewController: SubscriptionViewController())
        nc.modalPresentationStyle = .fullScreen
        return nc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        CKContainer.default().bootstrapKeys()
        CKContainer.default().fetchAllGroups()
        CKContainer.default().subscribeToInbox()
        CKContainer.default().fetchUnreadMessages()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        present(camera, animated: false) {}
    }
}

extension LoggedInViewController: ViewBootstrappable {
    func configureViews() {
        view.addSubview(tag)
        tag.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tag.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
