// RenameGroupViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import UIKit

class RenameGroupViewController: UIAlertController {
    var groupName: String?
    lazy var cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        // NO op
    }

    lazy var renameAction = UIAlertAction(title: "Rename", style: .default) { _ in
        guard let record = Current.cloudKitSelectedGroupSubject.value,
            let newGroupName = self.textFields?.first?.text else { return }
        CKContainer.default().updateGroup(recordID: record.recordID, name: newGroupName) { _ in
            CKContainer.default().fetchAllGroups()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addTextField()
        textFields?.first?.placeholder = groupName
        textFields?.first?.text = groupName
        textFields?.first?.clearButtonMode = .whileEditing
        textFields?.first?.delegate = self

        renameAction.isEnabled = false

        addAction(cancelAction)
        addAction(renameAction)
    }
}

extension RenameGroupViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let isEnabled = !(textField.text == textField.placeholder || textField.text?.isEmpty ?? true)
        actions.first(where: { $0.title == "Rename" })?.isEnabled = isEnabled
    }
}
