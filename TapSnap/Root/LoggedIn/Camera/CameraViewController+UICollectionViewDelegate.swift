//
//  CameraViewController+UICollectionViewDelegate.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/6/20.
//

import UIKit

extension CameraViewController: UICollectionViewDelegate {
 
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        contactPageControl.currentPage = Int(scrollView.contentOffset.x / UIScreen.main.bounds.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
       Current.recordingSubject.value = .start
        let cell = collectionView.cellForItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        Current.recordingSubject.value = .stop
    }
}
