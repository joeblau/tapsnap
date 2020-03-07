// MenuViewController+UITableViewDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

extension MenuViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case IndexPath(row: 1, section: 2):
            let myGroups = MyGroupsViewController()
            navigationController?.pushViewController(myGroups, animated: true)
        default: break
        }
    }
}
