//
//  CameraViewController+UIColl.swift
//  Dolo
//
//  Created by Joe Blau on 2/2/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

extension CameraViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return itemsInSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsInSection[section]
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactCollectionViewCell.id,
                                                      for: indexPath)
        
//        switch indexPath.section {
//        case 0: cell.contentView.backgroundColor = .red
//        case 1: cell.contentView.backgroundColor = .orange
//        case 2: cell.contentView.backgroundColor = .yellow
//        case 3: cell.contentView.backgroundColor = .green
//        default: cell.contentView.backgroundColor = .
//        }
        
        return cell
    }
}
