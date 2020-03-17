// LoggedOutViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit
import CloudKit

class LoggedOutViewController: UIViewController {

    lazy var loginButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Login", for: .normal)
        b.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Logged Out"
        UserDefaults.standard.removeObject(forKey: Current.k.userAccount)
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
