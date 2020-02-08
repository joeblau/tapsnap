//
//  MenuCellTableViewCell.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/7/20.
//

import UIKit

final class MenuCellTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imageView?.tintColor = .label
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Resuse Identifier
    
    static let id = String(describing: MenuCellTableViewCell.self)
}
