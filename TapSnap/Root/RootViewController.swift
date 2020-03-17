// RootViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import Combine
import os.log
import UIKit

class RootViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()

    lazy var tag: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .tertiarySystemBackground
        l.text = self.title
        return l
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        bootstrap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        title = "Root"
        
        switch UserDefaults.standard.data(forKey: Current.k.userAccount) {
        case .some: login()
        case .none:
            CKContainer.default().requestApplicationPermission(.userDiscoverability) { status, error in
                switch error {
                case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
                case .none: break
                }

                switch status {
                case .granted: CKContainer.default().currentUser()
                case .couldNotComplete, .denied, .initialState: self.logout()
                @unknown default: os_log("Unknown applicatoin permissions", log: .cloudKit, type: .error)
                }
            }
        }
    }

    // MARK: - Private

    private func login() {
        DispatchQueue.main.async {
            switch self.presentedViewController {
            case let .some(presented):
                switch presented {
                case is LoggedInViewController: break
                default: presented.dismiss(animated: true,
                                           completion: { self.showLogin() })
                }
            case .none:
                self.showLogin()
            }
        }
    }

    private func logout() {
        DispatchQueue.main.async {
            switch self.presentedViewController {
            case let .some(presented):
                switch presented {
                case is LoggedOutViewController: break
                default: presented.dismiss(animated: true,
                                           completion: { self.showLogout() })
                }
            case .none:
                self.showLogout()
            }
        }
    }

    private func showLogin() {
        let loggedIn = LoggedInViewController()
        loggedIn.modalPresentationStyle = .fullScreen
        present(loggedIn, animated: true, completion: nil)
    }

    private func showLogout() {
        let loggedOut = UINavigationController(rootViewController: LoggedOutViewController())
        loggedOut.modalPresentationStyle = .fullScreen
        present(loggedOut, animated: true, completion: nil)
    }
}

// MARK: - ViewBootstrappable

extension RootViewController: ViewBootstrappable {
    func configureViews() {
        view.addSubview(tag)
        tag.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        tag.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func configureStreams() {
        Current.cloudKitUserSubject.sink { record in
            switch record {
            case .some: self.login()
            case .none: self.logout()
            }
        }.store(in: &cancellables)
    }
}
