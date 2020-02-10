// RootViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import AuthenticationServices
import UIKit

class RootViewController: UIViewController {
    let provider = ASAuthorizationAppleIDProvider()

    // MARK: - Lifecycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        #if DEBUG
            let loggedIn = LoggedInViewController()
            loggedIn.modalPresentationStyle = .fullScreen
            present(loggedIn, animated: true, completion: nil)
        #else
            let doloUID = UserDefaults.standard.value(forKey: "doloUID") as? String ?? ""

            provider.getCredentialState(forUserID: doloUID) { credentialState, error in
                DispatchQueue.main.async {
                    switch credentialState {
                    case .authorized:
                        let loggedIn = LoggedInViewController()
                        loggedIn.modalPresentationStyle = .fullScreen
                        self.present(loggedIn, animated: true, completion: nil)
                    case .revoked, .notFound, .transferred:
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        let loggedOut = LoggedOutViewController()
                        loggedOut.modalPresentationStyle = .fullScreen
                        self.present(loggedOut, animated: true, completion: nil)
                    @unknown default:
                        break
                    }
                }
            }
        #endif
    }
}
