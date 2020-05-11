// SavedTapsViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

final class SavedTapsViewController: UIViewController {
    lazy var searchController: UISearchController = {
        let s = UISearchController(searchResultsController: nil)
        s.searchBar.autocapitalizationType = .none
        s.obscuresBackgroundDuringPresentation = false
        s.delegate = self
        s.searchBar.delegate = self
        s.searchBar.showsScopeBar = true
        s.searchBar.scopeButtonTitles = [L10n.titleSortByDate, L10n.titleSortByName]
        s.searchResultsUpdater = self
        return s
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.titleSavedTaps
        view.backgroundColor = .systemBackground
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
}
