// DeleteGroupViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import UIKit

class DeleteGroupViewController: UIAlertController {
    private let kConfirmationText = "CONFIRM"

    var groupName: String?
    lazy var cancelAction = UIAlertAction(title: L10n.titleCancel, style: .cancel) { _ in
        // NO op
    }

    lazy var deleteAction = UIAlertAction(title: L10n.titleDelete, style: .destructive) { _ in
        guard let record = Current.cloudKitSelectedGroupSubject.value else { return }
        CKContainer.default().removeGroup(recordID: record.recordID) { _ in
            CKContainer.default().fetchAllGroups()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addTextField()
        textFields?.first?.placeholder = kConfirmationText
        textFields?.first?.text = groupName
        textFields?.first?.clearButtonMode = .whileEditing
        textFields?.first?.delegate = self

        deleteAction.isEnabled = false

        addAction(cancelAction)
        addAction(deleteAction)
    }
}

extension DeleteGroupViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        actions.first(where: { $0.title == "Delete" })?.isEnabled = textField.text == kConfirmationText
    }
}
