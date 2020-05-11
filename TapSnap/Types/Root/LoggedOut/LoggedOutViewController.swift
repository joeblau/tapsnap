// LoggedOutViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import os.log
import UIKit

class LoggedOutViewController: UIViewController {
    lazy var loginButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(L10n.titleLogin, for: .normal)
        b.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = L10n.titleLoggedOut
        CKContainer.default().requestApplicationPermission(.userDiscoverability) { _, error in
            switch error {
            case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
            case .none: break
            }
        }
        bootstrap()
    }

    @objc func handleLogin() {
        CKContainer.default().currentUser()
    }
}

extension LoggedOutViewController: ViewBootstrappable {
    func configureViews() {
        view.addSubview(loginButton)
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
