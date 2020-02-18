//
//  SearchContactTableViewCell.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/17/20.
//

import UIKit

final class SearchContactTableViewCell: UITableViewCell {

    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        imageView?.image = UIImage(systemName: "person.crop.circle.fill")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    public func configure(image: UIImage,
                   friendName: String) {
        imageView?.image = image
        imageView?.contentMode = .scaleAspectFit
        textLabel?.text = friendName
    }
    
    // MARK: - Resuse Identifier

    static let id = String(describing: SearchContactTableViewCell.self)
    
}
