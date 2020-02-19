// SearchContactsTableView.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

class SearchContactsTableView: UITableView {
    var diffableDataSource: SearchContactsViewControllerDiffableDataSource?

    init() {
        super.init(frame: .zero, style: .plain)
        diffableDataSource = SearchContactsViewControllerDiffableDataSource(tableView: self)
        translatesAutoresizingMaskIntoConstraints = false
        tableFooterView = UIView()
        register(SearchContactTableViewCell.self,
                 forCellReuseIdentifier: SearchContactTableViewCell.id)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
