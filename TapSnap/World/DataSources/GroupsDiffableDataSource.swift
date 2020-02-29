// CameraViewControllerDiffableDataSource.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

class GroupsDiffableDataSource: UICollectionViewDiffableDataSource<GroupSection, GroupValue> {
    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { (collectionView, indexPath, groupValue) -> UICollectionViewCell? in

            switch indexPath.section {
            case 0:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactCollectionViewCell.id,
                                                              for: indexPath) as? ContactCollectionViewCell
                cell?.configure(image: groupValue.image,
                                title: groupValue.name,
                                record: groupValue.record,
                                groupSize: groupValue.participantCount)
                return cell
            case 1:
                return collectionView.dequeueReusableCell(withReuseIdentifier: ContactAddCollectionViewCell.id,
                                                          for: indexPath) as? ContactAddCollectionViewCell
            default:
                return nil
            }
        }
    }
}
