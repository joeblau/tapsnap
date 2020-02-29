//
//  MyGroupsCollectionViewCell.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/29/20.
//

import UIKit

class MyGroupCollectionViewCell: UICollectionViewCell {
    
    override init(frame _: CGRect) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let id = String(describing: MyGroupCollectionViewCell.self)

}
