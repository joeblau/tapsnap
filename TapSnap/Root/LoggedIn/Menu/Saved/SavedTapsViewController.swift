//
//  SavedTapsViewController.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/7/20.
//

import UIKit

final class SavedTapsViewController: UIViewController {
    
    lazy var searchController: UISearchController = {
        let s = UISearchController(searchResultsController: nil)
        s.searchBar.autocapitalizationType = .none
        s.obscuresBackgroundDuringPresentation = false
        s.delegate = self
        s.searchBar.delegate = self
        s.searchBar.showsScopeBar = true
        s.searchBar.scopeButtonTitles = ["Sort by Date", "Sort by Name"]
        s.searchResultsUpdater = self
        return s
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Saved Taps"
        view.backgroundColor = .systemBackground
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }

}
