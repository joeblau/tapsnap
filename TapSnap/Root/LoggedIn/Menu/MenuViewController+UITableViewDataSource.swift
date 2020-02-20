// MenuViewController+UITableViewDataSource.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

extension MenuViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        menuSections.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0..<menuSections.count: return menuSections[section].menuItems.count
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
        case IndexPath(row: 0, section: 3):
            let cell = tableView.dequeueReusableCell(withIdentifier: AutoSaveTapsTableViewCell.id, for: indexPath)
            let menuItem = menuSections[indexPath.section].menuItems[indexPath.row]
            cell.imageView?.image = UIImage(systemName: menuItem.systemName)
            cell.textLabel?.text = menuItem.titleText
            cell.detailTextLabel?.text = menuItem.subtitleText
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: MenuCellTableViewCell.id, for: indexPath)
            let menuItem = menuSections[indexPath.section].menuItems[indexPath.row]
            cell.imageView?.image = UIImage(systemName: menuItem.systemName)
            cell.textLabel?.text = menuItem.titleText
            return cell
        }
    }
}
