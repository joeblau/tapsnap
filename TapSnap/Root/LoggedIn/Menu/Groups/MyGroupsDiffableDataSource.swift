//
//  MyGroupsDiffableDataSource.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/29/20.
//

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
