// SearchContactsViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

final class SearchContactsViewController: UIViewController {
    lazy var emptyView: EmptyDataView = {
        EmptyDataView()
    }()
    
    lazy var searchController: UISearchController = {
        let s = UISearchController(searchResultsController: nil)
        s.searchBar.autocapitalizationType = .none
        s.obscuresBackgroundDuringPresentation = false
        s.delegate = self
        s.searchBar.delegate = self
        s.searchResultsUpdater = self
        return s
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        view.backgroundColor = .systemBackground
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        bootstrap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        Current.cloudKitManager.findAllFriendsWithApp()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emptyView.startAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emptyView.stopAnimation()
    }
    
    
}

extension SearchContactsViewController: ViewBootstrappable {
    func configureStreams() {
        view.addSubview(emptyView)
        emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
