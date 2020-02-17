// RootViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import os.log
import UIKit

class RootViewController: UIViewController {
    // MARK: - Lifecycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CKContainer.default().requestApplicationPermission(.userDiscoverability) { status, error in
            switch error {
            case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
            case .none: break
            }

            switch status {
            case .granted: self.cloudKitAccessGranted()
            case .couldNotComplete, .denied, .initialState: self.cloudKitAccessNotGranted()
            @unknown default: os_log("Unknown applicatoin permissions", log: .cloudKit, type: .error)
            }
        }
    }

    // MARK: - Private

    private func cloudKitAccessNotGranted() {
        DispatchQueue.main.async {
            let loggedOut = LoggedOutViewController()
            loggedOut.modalPresentationStyle = .fullScreen
            self.present(loggedOut, animated: true, completion: nil)
        }
    }

    private func cloudKitAccessGranted() {
        CKContainer.default().fetchUserRecordID { recordID, error in
            switch error {
            case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
            case .none: break
            }

            guard let recordID = recordID else {
                os_log("Unknown record ID", log: .cloudKit, type: .error)
                return
            }
            self.discoverUserIdentity(with: recordID)
        }
    }

    private func discoverUserIdentity(with recordId: CKRecord.ID) {
        CKContainer.default().discoverUserIdentity(withUserRecordID: recordId, completionHandler: { userID, error in
            switch error {
            case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
            case .none: break
            }

            guard let userID = userID else {
                os_log("Uninitialized user ID", log: .cloudKit, type: .error)
                return
            }

            Current.cloudKitUserSubject.send(userID)
            DispatchQueue.main.async {
                let loggedIn = LoggedInViewController()
                loggedIn.modalPresentationStyle = .fullScreen
                self.present(loggedIn, animated: true, completion: nil)
            }
        })
    }
}
