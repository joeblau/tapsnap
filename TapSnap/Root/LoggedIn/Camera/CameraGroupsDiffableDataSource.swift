// CameraViewControllerDiffableDataSource.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

class CameraGroupsDiffableDataSource: UICollectionViewDiffableDataSource<GroupSection, GroupValue> {
    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { (collectionView, indexPath, groupValue) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactCollectionViewCell.id,
                                                                for: indexPath) as? ContactCollectionViewCell,
                let record = groupValue.record else { return nil }
            cell.configure(record: record)
            return cell
        }
    }
}
