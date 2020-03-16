//
//  RenameGroupViewController.swift
//  Tapsnap
//
//  Created by Joe Blau on 3/15/20.
//

import UIKit
import CloudKit

class RenameGroupViewController: UIAlertController {

    var groupName: String?
    lazy var cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action  in
                // NO op
            }
            
    lazy var renameAction = UIAlertAction(title: "Rename", style: .default) { action in
        guard let record = Current.cloudKitSelectedGroupSubject.value,
            let newGroupName = self.textFields?.first?.text else { return }
        CKContainer.default().updateGroup(recordID: record.recordID, name: newGroupName) { isSaved in
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
        actions.first(where: { $0.title == "Rename"})?.isEnabled = isEnabled
    }
}
