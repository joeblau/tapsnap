//
//  MyGroupsViewController.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/29/20.
//

import UIKit
import Combine

class MyGroupsViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()

    private lazy var myGroupsCollectionView: MyGorupsCollectionView = {
        let v = MyGorupsCollectionView()
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Groups"
        bootstrap()
    }
}

extension MyGroupsViewController: ViewBootstrappable {
    func configureViews() {
        view.addSubview(myGroupsCollectionView)
        myGroupsCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        myGroupsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        myGroupsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        myGroupsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    func configureStreams() {
        Current.cloudKitGroupsSubject.sink { groups in

            guard let items = groups?.compactMap({ record -> GroupValue? in
                guard let name = record["name"] as? String else { return nil }
                return GroupValue(name: name, record: record)
            }) else {
                return
            }

            var snapshot = NSDiffableDataSourceSnapshot<GroupSection, GroupValue>()
            snapshot.appendSections([.groups])
            snapshot.appendItems(items, toSection: .groups)
            self.myGroupsCollectionView.diffableDataSource?.apply(snapshot)

        }.store(in: &cancellables)
    }
}
