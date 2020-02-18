// NowPlayingPreviewTableViewCell.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

final class NowPlayingPreviewTableViewCell: UITableViewCell {
    private lazy var artworkImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 8
        return iv
    }()

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 0
        l.font = UIFont.preferredFont(forTextStyle: .headline)
        return l
    }()

    private lazy var artistLabel: UILabel = {
        UILabel()
    }()

    private lazy var contentStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, artistLabel, UIView()])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.distribution = .fill
        return sv
    }()

    override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        bootstrap()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(image: UIImage?,
                   title: String?,
                   artist: String?) {
        artworkImageView.image = image
        titleLabel.text = title
        artistLabel.text = artist
    }

    static let id = String(describing: NowPlayingPreviewTableViewCell.self)
}

// MARK: - ViewBootstrappable

extension NowPlayingPreviewTableViewCell: ViewBootstrappable {
    internal func configureViews() {
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 132).isActive = true

        contentView.addSubview(artworkImageView)
        artworkImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        artworkImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        artworkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        artworkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        artworkImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16).isActive = true

        contentView.addSubview(contentStackView)
        contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        contentStackView.leadingAnchor.constraint(equalTo: artworkImageView.trailingAnchor, constant: 16).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
    }
}
