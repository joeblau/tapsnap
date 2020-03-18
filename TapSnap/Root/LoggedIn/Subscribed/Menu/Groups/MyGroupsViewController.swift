// MyGroupsViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import Combine
import UIKit
import os.log

class MyGroupsViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()
    private var newGroupName: String?
    
    lazy var newGroup: NewGroupViewController = {
        let c = NewGroupViewController(title: "New Group",
                               message: "Enter a name for your new group",
                               preferredStyle: .alert)
        c.delegate = self
        return c
    }()

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
        present(newGroup, animated: true)
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
                    return GroupValue(record: record)
                }

                switch items.isEmpty {
                case true: break
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

extension MyGroupsViewController: NewGroupViewControllerDelegate {
    
    func createNewGroup(with name: String) {
        newGroupName = name
        CKContainer.default().createNewGroup(with: name, from: self)
    }
}

extension MyGroupsViewController: UICloudSharingControllerDelegate {
    public func cloudSharingController(_: UICloudSharingController, failedToSaveShareWithError error: Error) {
        os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
    }

    public func itemTitle(for _: UICloudSharingController) -> String? {
        newGroupName ?? "-"
    }

    public func itemThumbnailData(for _: UICloudSharingController) -> Data? {
        UIImage(systemName: "video.fill")?.pngData()
    }
}

