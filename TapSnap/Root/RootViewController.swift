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
        let c = UINavigationController()
        c.navigationBar.prefersLargeTitles = true
        c.modalPresentationStyle = .fullScreen
        return c
    }()

    // MARK: - Onboarding

    lazy var onboardingICloud: OnboardingViewController = {
        OnboardingViewController(title: "iCloud",
                                 image: UIImage(systemName: "icloud.fill"),
                                 description: "Tapsnap uses your iCloud Apple ID account as your account. You will not be able to use Tapsnap without an iCloud account.",
                                 buttonText: "Prompt Authorization",
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
                                             CKContainer.default().currentUser()
                                             DispatchQueue.main.async {
                                                 self.onboarding.pushViewController(self.onboardingCamera, animated: true)
                                             }
                                         case .couldNotComplete, .denied, .initialState:
                                             DispatchQueue.main.async {
                                                 UIApplication.shared.open(URL(string: "App-Prefs:root=General")!, options: [:], completionHandler: nil)
                                             }
                                        @unknown default: os_log("Unknown applicatoin permissions", log: .cloudKit, type: .error)
                                         }
                                     }
        })
    }()

    lazy var onboardingCamera: OnboardingViewController = {
        OnboardingViewController(title: "Camera",
                                 image: UIImage(systemName: "camera.fill"),
                                 description: "Tapsnap is a video and photo app and uses your camera to create vidoes and photos.",
                                 buttonText: "Prompt Authorization",
                                 valueAction: { [unowned self] _ in

                                     AVCaptureDevice.requestAccess(for: .video) { granted in
                                         switch granted {
                                         case true:
                                             DispatchQueue.main.async {
                                                 self.onboarding.pushViewController(self.onboardingMicrophone, animated: true)
                                             }
                                         case false: print("go to settings")
                                         }
                                     }
        })
    }()

    lazy var onboardingMicrophone: OnboardingViewController = {
        OnboardingViewController(title: "Microphone",
                                 image: UIImage(systemName: "mic.fill"),
                                 description: "Tapsnap uses your microphone to record your voice and audio for your video taps.",
                                 buttonText: "Prompt Authorization",
                                 valueAction: { [unowned self] _ in

                                     AVCaptureDevice.requestAccess(for: .audio) { granted in
                                         switch granted {
                                         case true:
                                             DispatchQueue.main.async {
                                                 self.onboarding.pushViewController(self.onboardingNotifications, animated: true)
                                             }
                                         case false: print("go to settings")
                                         }
                                     }
        })
    }()

    lazy var onboardingNotifications: OnboardingViewController = {
        OnboardingViewController(title: "Notifictions",
                                 image: UIImage(systemName: "app.badge.fill"),
                                 description: "Tapsnap can alert you whenever new messages are avaiable.",
                                 buttonText: "Prompt Authorization",
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
        OnboardingViewController(title: "Location",
                                 image: UIImage(systemName: "location.fill"),
                                 description: "Tapsnap can share your location with your taps.",
                                 buttonText: "Prompt Authorization",
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
        switch UserDefaults.standard.bool(forKey: Current.k.isOnboardingComplete) {
        case false: showOnboarding()
        case true: CKContainer.default().currentUser()
        }
    }

    // MARK: - Private

    private func showOnboarding() {
        onboarding.viewControllers = [onboardingICloud]
        present(onboarding, animated: true, completion: nil)
    }

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
}

// MARK: - ViewBootstrappable

extension RootViewController: ViewBootstrappable {
    func configureStreams() {
        Current.currentLocationAuthorizationSubject
            .removeDuplicates()
            .sink { status in
                switch status {
                case .authorizedWhenInUse:
                    UserDefaults.standard.set(true, forKey: Current.k.isOnboardingComplete)
                    DispatchQueue.main.async {
                        self.onboarding.dismiss(animated: true) {
                            self.login()
                        }
                    }
                default: break
                }
            }.store(in: &cancellables)

        Current.cloudKitUserSubject
            .removeDuplicates()
            .sink { record in
                guard UserDefaults.standard.bool(forKey: Current.k.isOnboardingComplete) else { return }
                switch record {
                case .some:
                    self.login()
                case .none:
                    self.logout()
                }
            }.store(in: &cancellables)
    }
}
