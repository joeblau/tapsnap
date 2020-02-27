// SearchContactsViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import Combine
import UIKit
import CloudKit

final class SearchContactsViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()

    private lazy var contactsTableView: SearchContactsTableView = {
        SearchContactsTableView()
    }()

    private lazy var emptyView: EmptyDataView = {
        let v = EmptyDataView()
        v.alpha = 0.0
        return v
    }()

    private lazy var searchController: UISearchController = {
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
        CKContainer.default().fetchAllFriendsWithApp()
    }

    private var isEmptyVisible: Bool = false {
        didSet {
            guard oldValue != isEmptyVisible else { return }
            switch isEmptyVisible {
            case true:
                DispatchQueue.main.async {
                    self.emptyView.isHidden = false
                    self.emptyView.startAnimation()
                    UIView.animate(withDuration: 0.3) {
                        self.emptyView.alpha = 1.0
                    }
                }
            case false:
                DispatchQueue.main.async {
                    self.emptyView.stopAnimation()
                    UIView.animate(withDuration: 0.3,
                                   animations: {
                                       self.emptyView.alpha = 0.0
                    }) { complated in
                        guard complated else { return }
                        self.emptyView.isHidden = true
                    }
                }
            }
        }
    }
}

extension SearchContactsViewController: ViewBootstrappable {
    func configureViews() {
        view.addSubview(contactsTableView)
        contactsTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contactsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contactsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contactsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        view.addSubview(emptyView)
        emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    func configureStreams() {
        Current.cloudKitFriendsSubject.sink { friends in
            switch friends {
            case let .some(friends):
                self.isEmptyVisible = false
                let items = friends.compactMap { identity -> SearchContactsValue? in
                    guard let personName = identity.nameComponents else { return nil }

                    let name = Current.formatter.personName.annotatedString(from: personName)
                    return SearchContactsValue(name: name.string)
                }

                var snapshot = NSDiffableDataSourceSnapshot<SearchContactsSection, SearchContactsValue>()
                snapshot.appendSections([.friends])
                snapshot.appendItems(items, toSection: .friends)
                self.contactsTableView.diffableDataSource?.apply(snapshot)

            case .none: break
            }
        }.store(in: &cancellables)
    }
}
