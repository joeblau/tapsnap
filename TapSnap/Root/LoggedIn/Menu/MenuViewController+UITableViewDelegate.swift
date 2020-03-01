//
//  MenuViewController+UITableViewDelegate.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/29/20.
//

import UIKit

extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case IndexPath(row: 1, section: 2):
            let myGroups = MyGroupsViewController()
            navigationController?.pushViewController(myGroups, animated: true)
        default: break
        }
    }
}
