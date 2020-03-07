// MyGroupsViewController+UICollectionViewDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import UIKit

extension MyGroupsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MyGroupCollectionViewCell,
            let record = cell.record else {
            fatalError("Invalid cell type")
        }
        CKContainer.default().manage(group: record, sender: self)
    }
}
