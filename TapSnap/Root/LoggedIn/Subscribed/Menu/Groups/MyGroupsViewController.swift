// MyGroupsViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import Combine
import UIKit

class MyGroupsViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .large)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var myGroupsCollectionView: MyGorupsCollectionView = {
        let v = MyGorupsCollectionView()
        v.delegate = self
        v.refreshControl?.addTarget(self, action: #selector(refreshGroupsAction), for: .valueChanged)
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Groups"
        activityIndicatorView.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newGroupAction))
        bootstrap()
    }

    // MARK: - Actions

    @objc func newGroupAction() {
        let newGroupAlert = UIAlertController(title: "New Group Name", message: nil, preferredStyle: .alert)
        newGroupAlert.addTextField()
        let submitAction = UIAlertAction(title: "Craete Group", style: .default) { [unowned newGroupAlert] _ in
            guard let groupName = newGroupAlert.textFields?.first?.text else { return }
            CKContainer.default().createNewGroup(with: groupName, from: self)
        }

        newGroupAlert.addAction(submitAction)
        present(newGroupAlert, animated: true)
    }

    @objc func refreshGroupsAction() {
        CKContainer.default().fetchAllGroups()
    }
}

extension MyGroupsViewController: ViewBootstrappable {
    func configureViews() {
        view.addSubview(myGroupsCollectionView)
        myGroupsCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        myGroupsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        myGroupsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        myGroupsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        view.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: myGroupsCollectionView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: myGroupsCollectionView.centerYAnchor).isActive = true
    }

    func configureStreams() {
        Current.cloudKitGroupsSubject.sink { [unowned self] groups in
            guard let groups = groups else { return }

            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
                self.myGroupsCollectionView.refreshControl?.endRefreshing()

                let items = groups.compactMap { record -> GroupValue? in
                    guard let name = record["name"] as? String else { return nil }
                    return GroupValue(name: name, record: record)
                }

                switch items.isEmpty {
                case true: print("no groups")
                case false:
                    var snapshot = NSDiffableDataSourceSnapshot<GroupSection, GroupValue>()
                    snapshot.appendSections([.groups])
                    snapshot.appendItems(items, toSection: .groups)
                    self.myGroupsCollectionView.diffableDataSource?.apply(snapshot)
                }
            }
        }.store(in: &cancellables)
    }
}
