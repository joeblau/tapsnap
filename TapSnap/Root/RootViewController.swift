//
//  RootViewController.swift
//  Dolo
//
//  Created by Joe Blau on 1/31/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit
import AuthenticationServices

class RootViewController: UIViewController {
    let provider = ASAuthorizationAppleIDProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        #if DEBUG
            let loggedIn = LoggedInViewController()
            loggedIn.modalPresentationStyle = .fullScreen
            self.present(loggedIn, animated: true, completion: nil)
        #else
            let doloUID = UserDefaults.standard.value(forKey: "doloUID") as? String ?? ""

            provider.getCredentialState(forUserID: doloUID) { (credentialState, error) in
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
