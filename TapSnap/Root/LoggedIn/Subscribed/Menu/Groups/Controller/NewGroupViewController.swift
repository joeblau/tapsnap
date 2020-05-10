// NewGroupViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

protocol NewGroupViewControllerDelegate {
    func createNewGroup(with name: String)
}

class NewGroupViewController: UIAlertController {
    weak var delegate: NewGroupViewControllerDelegate?
    lazy var cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        // NO op
    }

    lazy var createAction = UIAlertAction(title: "Create", style: .default) { _ in
        guard let groupName = self.textFields?.first?.text else { return }
        self.delegate?.createNewGroup(with: groupName)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addTextField()
        textFields?.first?.placeholder = "Group name"
        textFields?.first?.clearButtonMode = .whileEditing
        textFields?.first?.delegate = self

        createAction.isEnabled = false

        addAction(cancelAction)
        addAction(createAction)
    }
}

extension NewGroupViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        actions.first(where: { $0.title == "Create" })?.isEnabled = !(textField.text?.isEmpty ?? false)
    }
}
