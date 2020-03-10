// MenuViewController+UITableViewDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case IndexPath(row: 1, section: 2):
            let myGroups = MyGroupsViewController()
            navigationController?.pushViewController(myGroups, animated: true)
        case IndexPath(row: 0, section: 3):
            var autoSave = UserDefaults.standard.bool(forKey: Current.k.autoSave)
            autoSave.toggle()
            UserDefaults.standard.set(autoSave, forKey: Current.k.autoSave)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case IndexPath(row: 1, section: 3):
            guard let settings = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settings)
        default: break
        }
    }
}
