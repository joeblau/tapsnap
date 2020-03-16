//
//  NewGroupViewController.swift
//  Tapsnap
//
//  Created by Joe Blau on 3/15/20.
//

import UIKit
import CloudKit

class NewGroupViewController: UIAlertController {

    var groupName: String?
    lazy var cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action  in
                // NO op
            }
            
    lazy var createAction = UIAlertAction(title: "Create", style: .default) { action in
        guard let groupName = self.textFields?.first?.text else { return }
        CKContainer.default().createNewGroup(with: groupName, from: self)
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
        actions.first(where: { $0.title == "Create"})?.isEnabled = !(textField.text?.isEmpty ?? false)
    }
}
