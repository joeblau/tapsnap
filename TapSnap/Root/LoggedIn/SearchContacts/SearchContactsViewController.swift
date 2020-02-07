//
//  SearchContactsViewController.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/7/20.
//

import UIKit

class SearchContactsViewController: UIViewController {

    lazy var searchController: UISearchController = {
        let s = UISearchController(searchResultsController: nil)
        s.searchBar.autocapitalizationType = .none
        s.obscuresBackgroundDuringPresentation = false
        s.delegate = self
        s.searchBar.delegate = self
//        s.searchBar.showsScopeBar = true
//        s.searchBar.scopeButtonTitles = ["List", "Map"]
        s.searchResultsUpdater = self
        return s
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        view.backgroundColor = .systemBackground
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
}
