// RootViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import AVFoundation
import CloudKit
import Combine
import os.log
import UIKit

class RootViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    lazy var onboarding: UINavigationController = {
        let c = UINavigationController(rootViewController: onboardingICloud)
        c.navigationBar.prefersLargeTitles = true
        c.modalPresentationStyle = .fullScreen
        return c
    }()

    // MARK: - Onboarding

    lazy var onboardingICloud: OnboardingViewController = {
        OnboardingViewController(title: L10n.titleIcloud,
                                 image: UIImage(systemName: "icloud.fill"),
                                 description: L10n.bodyIcloudUse,
                                 buttonText: L10n.promptAuthorization,
                                 valueAction: { [unowned self] controller in

                                     CKContainer.default().requestApplicationPermission(.userDiscoverability) { status, error in
                                         switch error {
                                         case let .some(error):
                                             os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
                                             controller.show(error: error.localizedDescription)
                                         case .none: break
                                         }

                                         switch status {
                                         case .granted:
                                             DispatchQueue.main.async {
                                                 CKContainer.default().currentUser()
                                                 self.onboarding.pushViewController(self.onboardingCamera, animated: true)
                                             }
                                         case .couldNotComplete, .denied, .initialState:
                                             self.openSettings()
                                        @unknown default: os_log("Unknown applicatoin permissions", log: .cloudKit, type: .error)
                                         }
                                     }
        })
    }()

    lazy var onboardingCamera: OnboardingViewController = {
        OnboardingViewController(title: L10n.titleCamera,
                                 image: UIImage(systemName: "camera.fill"),
                                 description: L10n.bodyCameraUse,
                                 buttonText: L10n.promptAuthorization,
                                 valueAction: { [unowned self] _ in

                                     AVCaptureDevice.requestAccess(for: .video) { granted in
                                         switch granted {
                                         case true:
                                             DispatchQueue.main.async {
                                                 self.onboarding.pushViewController(self.onboardingMicrophone, animated: true)
                                             }
                                         case false: self.openSettings()
                                         }
                                     }
        })
    }()

    lazy var onboardingMicrophone: OnboardingViewController = {
        OnboardingViewController(title: L10n.titleMicrophone,
                                 image: UIImage(systemName: "mic.fill"),
                                 description: L10n.bodyMicrophoneUse,
                                 buttonText: L10n.promptAuthorization,
                                 valueAction: { [unowned self] _ in

                                     AVCaptureDevice.requestAccess(for: .audio) { granted in
                                         switch granted {
                                         case true:
                                             DispatchQueue.main.async {
                                                 self.onboarding.pushViewController(self.onboardingNotifications, animated: true)
                                             }
                                         case false: self.openSettings()
                                         }
                                     }
        })
    }()

    lazy var onboardingNotifications: OnboardingViewController = {
        OnboardingViewController(title: L10n.titleNotifications,
                                 image: UIImage(systemName: "app.badge.fill"),
                                 description: L10n.bodyNotificationsUse,
                                 buttonText: L10n.promptAuthorization,
                                 valueAction: { [unowned self] _ in

                                     UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
                                         switch error {
                                         case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
                                         case .none: break
                                         }

                                         DispatchQueue.main.async {
                                             self.onboarding.pushViewController(self.onboardingLocation, animated: true)
                                         }
                                     }
        })
    }()

    lazy var onboardingLocation: OnboardingViewController = {
        OnboardingViewController(title: L10n.titleLocation,
                                 image: UIImage(systemName: "location.fill"),
                                 description: L10n.bodyLocationUse,
                                 buttonText: L10n.promptAuthorization,
                                 valueAction: { [unowned self] _ in
                                     Current.locationManager.requestWhenInUseAuthorization()

        })
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        bootstrap()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch UserDefaults.standard.bool(forKey: Constant.isOnboardingComplete) {
        case false: present(onboarding, animated: true, completion: nil)
        case true: CKContainer.default().currentUser()
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
        present(loggedIn, animated: false, completion: nil)
    }

    private func showLogout() {
        let loggedOut = LoggedOutViewController()
        loggedOut.modalPresentationStyle = .fullScreen
        present(loggedOut, animated: true, completion: nil)
    }

    private func openSettings() {
        DispatchQueue.main.async {
            UIApplication.shared.open(URL(string: "App-Prefs:root=General")!, options: [:], completionHandler: nil)
        }
    }
}

// MARK: - ViewBootstrappable

extension RootViewController: ViewBootstrappable {
    func configureStreams() {
        Current.currentLocationAuthorizationSubject
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { status in
                switch status {
                case .authorizedWhenInUse:
                    UserDefaults.standard.set(true, forKey: Constant.isOnboardingComplete)
                    self.onboarding.dismiss(animated: true) {
                        self.login()
                    }
                default: break
                }
            }.store(in: &cancellables)

        Current.cloudKitUserSubject
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { record in
                guard UserDefaults.standard.bool(forKey: Constant.isOnboardingComplete) else { return }
                switch record {
                case .some: self.login()
                case .none: self.logout()
                }
            }.store(in: &cancellables)
    }
}
