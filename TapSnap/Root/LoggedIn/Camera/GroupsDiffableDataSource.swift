//
//  GroupsDiffableDataSource.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/16/20.
//

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
