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
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25),
                                                  heightDimension: .fractionalHeight(1.0))
            let contactItem = NSCollectionLayoutItem(layoutSize: itemSize)
            contactItem.contentInsets = NSDirectionalEdgeInsets(top: 1,
                                                              leading: 1,
                                                              bottom: 1,
                                                              trailing: 1)
        
            let containerGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(100.0)),
                subitems: [contactItem])
            
            let section = NSCollectionLayoutSection(group: containerGroup)
            section.orthogonalScrollingBehavior = .continuous
            
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
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
