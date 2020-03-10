// MyGroupsDiffableDataSource.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

class MyGroupsDiffableDataSource: UICollectionViewDiffableDataSource<GroupSection, GroupValue> {
    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { (collectionView, indexPath, groupValue) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyGroupCollectionViewCell.id,
                                                                for: indexPath) as? MyGroupCollectionViewCell,
                let record = groupValue.record else { return nil }
            cell.configure(record: record)
            return cell
        }
    }
}
