//
//  MyGroupsViewController+UICollectionViewDelegate.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/29/20.
//

import UIKit
import CloudKit

extension MyGroupsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MyGroupCollectionViewCell,
            let record = cell.record else {
            fatalError("Invalid cell type")
        }
        CKContainer.default().manage(group: record, sender: self)
    }
}
