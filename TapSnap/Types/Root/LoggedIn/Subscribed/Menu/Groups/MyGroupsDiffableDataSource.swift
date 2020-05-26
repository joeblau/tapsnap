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
        
        supplementaryViewProvider = { ( collectionView, kind, indexPath) -> UICollectionReusableView? in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                         withReuseIdentifier: GroupHeaderCollectionReusableView.id,
                                                                         for: indexPath) as? GroupHeaderCollectionReusableView
            switch indexPath.section {
            case GroupSection.ownedGroups.rawValue: header?.configure(text: L10n.ownedGroups)
            case GroupSection.memberGroups.rawValue: header?.configure(text: L10n.memberGroups)
            default: preconditionFailure("Unknown group")
            }
            return header
        }
    }
}
