// CameraViewController+UICollectionViewDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import UIKit

extension CameraViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        contactPageControl.currentPage = Int(scrollView.contentOffset.x / UIScreen.main.bounds.width)
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath {
        case IndexPath(row: 0, section: 1):
            break
//            CKContainer.default().create
//            Current.cloudKitManager.createNewGroup(sender: self)
        default: break
        }
    }
}
