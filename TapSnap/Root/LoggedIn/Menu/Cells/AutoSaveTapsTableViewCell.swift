//
//  ToggleTableViewCell.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/18/20.
//

import UIKit

class AutoSaveTapsTableViewCell: UITableViewCell {
    
    lazy var toggleView: UISwitch = {
        let s = UISwitch()
        s.addTarget(self, action: #selector(toggleDownlaodingTaps(sender:)), for: . valueChanged)
        return s
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        imageView?.tintColor = .label
        toggleView.isOn = UserDefaults.standard.bool(forKey: Current.k.autoSave)
        accessoryView = toggleView
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let id = String(describing: AutoSaveTapsTableViewCell.self)
    
    @objc func toggleDownlaodingTaps(sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey:  Current.k.autoSave)
    }
}
