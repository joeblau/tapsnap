// LoggedOutViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

class LoggedOutViewController: UIViewController {
    lazy var stackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [logoView, errorLabel])
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .vertical
        return v
    }()

    lazy var logoView: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "video.fill"))
        v.translatesAutoresizingMaskIntoConstraints = false
        v.tintColor = .label
        return v
    }()

    lazy var errorLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        bootstrap()
    }

    @objc func handleAuthorizationAppleIDButtonPress() {}
}

extension LoggedOutViewController: ViewBootstrappable {
    func configureViews() {
        logoView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        logoView.heightAnchor.constraint(equalToConstant: 32).isActive = true

        view.addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
