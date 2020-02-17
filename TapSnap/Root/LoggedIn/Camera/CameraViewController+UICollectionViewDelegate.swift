// CameraViewController+UICollectionViewDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import UIKit

extension CameraViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        contactPageControl.currentPage = Int(scrollView.contentOffset.x / UIScreen.main.bounds.width)
    }
}
