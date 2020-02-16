// CameraViewController+UICollectionViewDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit
import CloudKit

extension CameraViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        contactPageControl.currentPage = Int(scrollView.contentOffset.x / UIScreen.main.bounds.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (1, 0): Current.cloudKitManager.createNewGroup(sender: self)
        default: break
        }
    }

}
