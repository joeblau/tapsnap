//
//  GroupHeaderCollectionReusableView.swift
//  Tapsnap
//
//  Created by Joe Blau on 5/26/20.
//

import UIKit

class GroupHeaderCollectionReusableView: UICollectionReusableView {
    
    lazy var textLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(textLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(text: String) {
        textLabel.text = text
    }
}
