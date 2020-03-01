//
//  MyGorupsCollectionView.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/29/20.
//

import UIKit

class MyGorupsCollectionView: UICollectionView {

    var diffableDataSource: MyGroupsDiffableDataSource?
    init() {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        super.init(frame: .zero, collectionViewLayout: layout)
        diffableDataSource = MyGroupsDiffableDataSource(collectionView: self)
        dataSource = diffableDataSource
        translatesAutoresizingMaskIntoConstraints = false
        showsHorizontalScrollIndicator = false
        backgroundColor = .systemBackground
        refreshControl = UIRefreshControl()
        register(MyGroupCollectionViewCell.self,
                 forCellWithReuseIdentifier: MyGroupCollectionViewCell.id)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
