// ContactsCollectionView.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

class ContactsCollectionView: UICollectionView {
    var diffableDataSource: CameraGroupsDiffableDataSource?
    init() {
        let hairline = 1.0 / UIScreen.main.scale
        let width = (UIScreen.main.bounds.width / 4) - hairline
        let height = (UIScreen.main.bounds.width / 4) - hairline

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = hairline
        flowLayout.minimumInteritemSpacing = hairline
        flowLayout.itemSize = CGSize(width: width, height: height)

        super.init(frame: .zero, collectionViewLayout: flowLayout)
        diffableDataSource = CameraGroupsDiffableDataSource(collectionView: self)
        dataSource = diffableDataSource

        translatesAutoresizingMaskIntoConstraints = false
        showsHorizontalScrollIndicator = false
        backgroundColor = .systemBackground
        isPagingEnabled = true
        register(ContactCollectionViewCell.self,
                 forCellWithReuseIdentifier: ContactCollectionViewCell.id)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
