//
//  SearchContactsTableView.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/17/20.
//

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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
