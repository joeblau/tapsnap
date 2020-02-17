// GroupsDiffableDataSource.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

class GroupsDiffableDataSource: UICollectionViewDiffableDataSource<GroupSection, GroupValue> {
    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { (collectionView, indexPath, groupValue) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactCollectionViewCell.id, for: indexPath) as? ContactCollectionViewCell
            cell?.configure(image: groupValue.image,
                            title: groupValue.name,
                            groupSize: groupValue.participantCount)
            return cell
        }
    }
}
