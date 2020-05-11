// MenuViewController+UITableViewDataSource.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

extension MenuViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        menuSections.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 ..< menuSections.count: return menuSections[section].menuItems.count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath {
        case IndexPath(row: 0, section: 0):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AvatarNameTableViewCell.id,
                                                           for: indexPath) as? AvatarNameTableViewCell else {
                fatalError("Could not create AvatarNameTableViewCell")
            }
            cell.avatarView.addTarget(self, action: #selector(updateAvatar), for: .touchUpInside)
            return cell
        case IndexPath(row: 0, section: 2):
            let cell = tableView.dequeueReusableCell(withIdentifier: ToggleTableViewCell.id, for: indexPath)
            let menuItem = menuSections[indexPath.section].menuItems[indexPath.row]
            (cell as? ToggleTableViewCell)?.configure(menuItem: menuItem, enabled: UserDefaults.standard.bool(forKey: Current.k.settingAutoSave))
            return cell
        case IndexPath(row: 1, section: 2):
            let cell = tableView.dequeueReusableCell(withIdentifier: ToggleTableViewCell.id, for: indexPath)
            let menuItem = menuSections[indexPath.section].menuItems[indexPath.row]
            (cell as? ToggleTableViewCell)?.configure(menuItem: menuItem, enabled: UserDefaults.standard.bool(forKey: Current.k.isVisualizerHidden))
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: MenuCellTableViewCell.id, for: indexPath)
            let menuItem = menuSections[indexPath.section].menuItems[indexPath.row]
            (cell as? MenuCellTableViewCell)?.configure(menuItem: menuItem)
            return cell
        }
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        menuSections[section].header
    }
}
