//
//  MyGroupsCollectionViewCell.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/29/20.
//

import UIKit
import CloudKit

class MyGroupCollectionViewCell: UICollectionViewCell {
    
    public private(set) var record: CKRecord?
    
    override init(frame _: CGRect) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(record: CKRecord) {
        self.record = record
    }
    
    static let id = String(describing: MyGroupCollectionViewCell.self)
}
