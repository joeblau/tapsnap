// LoggedOutViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import AuthenticationServices
import UIKit

class LoggedOutViewController: UIViewController {
    let stack: UIStackView
    let logoView = UIImageView(image: UIImage(named: "video.fill"))
    let signInButton = ASAuthorizationAppleIDButton()
    let errorLabel = UILabel()

    init() {
        logoView.translatesAutoresizingMaskIntoConstraints = false
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        stack = UIStackView(arrangedSubviews: [logoView, signInButton, errorLabel])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        signInButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)

        view.addSubview(stack)
        view.centerXAnchor.constraint(equalTo: stack.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: stack.centerYAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: stack.leadingAnchor, constant: -32).isActive = true
        view.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: 32).isActive = true
    }

    @objc func handleAuthorizationAppleIDButtonPress() {
        let appleIDRequest = ASAuthorizationAppleIDProvider().createRequest()
        appleIDRequest.requestedScopes = [.fullName]

        let requests = [appleIDRequest]

        let controller = ASAuthorizationController(authorizationRequests: requests)
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

extension LoggedOutViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller _: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let credential as ASAuthorizationAppleIDCredential:
            let userIdentifier = credential.user
            UserDefaults.standard.set(userIdentifier, forKey: "doloUID")
            dismiss(animated: true, completion: nil)
        default: break
        }
    }

    func authorizationController(controller _: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        errorLabel.text = error.localizedDescription
    }
}

extension LoggedOutViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
        view.window!
    }
}
