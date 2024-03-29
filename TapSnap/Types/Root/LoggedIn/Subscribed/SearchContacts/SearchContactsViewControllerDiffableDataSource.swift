// SearchContactsViewControllerDiffableDataSource.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

class SearchContactsViewControllerDiffableDataSource: UITableViewDiffableDataSource<SearchContactsSection, SearchContactsValue> {
    init(tableView: UITableView) {
        super.init(tableView: tableView) { (tableView, indexPath, searchContactValue) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchContactTableViewCell.id,
                                                           for: indexPath) as? SearchContactTableViewCell else {
                return nil
            }
            cell.configure(image: searchContactValue.image,
                           friendName: searchContactValue.name)
            return cell
        }
    }
}
