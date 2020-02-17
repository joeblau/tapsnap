// ContactsCollectionView.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

class ContactsCollectionView: UICollectionView {
    init() {
        let hairline = 1.0 / UIScreen.main.scale
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(0.5))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: hairline,
                                                     leading: hairline,
                                                     bottom: hairline,
                                                     trailing: hairline)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25),
                                               heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                     subitem: item,
                                                     count: 2)

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .paging
        let compositionalLayout = UICollectionViewCompositionalLayout(section: section)

        super.init(frame: .zero, collectionViewLayout: compositionalLayout)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
