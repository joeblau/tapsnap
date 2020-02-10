// MenuViewController+UITableViewDataSource.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

extension MenuViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        menuSections.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1, 2: return menuSections[section].menuItems.count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuCellTableViewCell.id, for: indexPath)
        let menuItem = menuSections[indexPath.section].menuItems[indexPath.row]
        cell.imageView?.image = UIImage(systemName: menuItem.systemName)
        cell.textLabel?.text = menuItem.titleText
        return cell
    }
}
