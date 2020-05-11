//
//  ResetKeysViewController.swift
//  Tapsnap
//
//  Created by Joe Blau on 5/10/20.
//

import CloudKit
import UIKit

class ResetKeysViewController: UIAlertController {
    var groupName: String?
    lazy var cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    lazy var resetAction = UIAlertAction(title: "Reset", style: .destructive) { _ in
        CKContainer.default().bootstrapKeys(reset: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTextField()
        textFields?.first?.placeholder = "RESET KEYS"
        textFields?.first?.clearButtonMode = .whileEditing
        textFields?.first?.delegate = self
        
        resetAction.isEnabled = false
        
        addAction(cancelAction)
        addAction(resetAction)
    }
}

extension ResetKeysViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        actions.first(where: { $0.title == "Reset" })?.isEnabled = textField.text == "RESET KEYS"
    }
}
