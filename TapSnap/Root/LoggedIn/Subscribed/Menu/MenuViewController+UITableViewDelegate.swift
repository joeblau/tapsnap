// MenuViewController+UITableViewDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case IndexPath(row: 1, section: 1):
            let myGroups = MyGroupsViewController()
            navigationController?.pushViewController(myGroups, animated: true)
        case IndexPath(row: 0, section: 2):
            var autoSave = UserDefaults.standard.bool(forKey: Current.k.settingAutoSave)
            autoSave.toggle()
            UserDefaults.standard.set(autoSave, forKey: Current.k.settingAutoSave)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case IndexPath(row: 1, section: 2):
            var visualizer = UserDefaults.standard.bool(forKey: Current.k.isVisualizerHidden)
            visualizer.toggle()
            Current.hideTouchVisuzlierSubject.send(visualizer)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case IndexPath(row: 0, section: 3):
            guard let settings = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settings)
        default: break
        }
    }
}
