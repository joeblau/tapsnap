// ContactsCollectionView.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

class ContactsCollectionView: UICollectionView {
    init() {
        let flowLayout = UICollectionViewFlowLayout()
        let width = (UIScreen.main.bounds.width / 4)
        let height = (UIScreen.main.bounds.width / 4) - 1
        flowLayout.itemSize = CGSize(width: width, height: height)
        flowLayout.minimumLineSpacing = 1
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: flowLayout)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
