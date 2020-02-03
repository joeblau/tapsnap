//
//  ContactsCollectionView.swift
//  Dolo
//
//  Created by Joe Blau on 2/2/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

class ContactsCollectionView: UICollectionView {
    
    init() {
        var contactLayout: UICollectionViewCompositionalLayout {
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(100),
                                                  heightDimension: .absolute(100))
            let contactItem = NSCollectionLayoutItem(layoutSize: itemSize)
            contactItem.contentInsets = NSDirectionalEdgeInsets(top: 1,
                                                                leading: 1,
                                                                bottom: 1,
                                                                trailing: 1)
            
            let containerGroup = NSCollectionLayoutGroup
                .vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25),
                                                             heightDimension: .absolute(200)),
                          subitems: [contactItem])
            
            
            let section = NSCollectionLayoutSection(group: containerGroup)
            
            let config = UICollectionViewCompositionalLayoutConfiguration()
            config.scrollDirection = .horizontal
            
            return UICollectionViewCompositionalLayout(section: section, configuration: config)
        }
        
        super.init(frame: .zero, collectionViewLayout: contactLayout)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
