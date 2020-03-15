// CurrentSongView.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

class CurrentSongView: UIView {
    private var songID: String?

    lazy var artworkView: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFit
        return v
    }()

    lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .label
        l.font = UIFont.preferredFont(forTextStyle: .headline)
        return l
    }()

    lazy var artistLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .label
        l.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return l
    }()

    lazy var currentSongStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [titleLabel, artistLabel])
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .vertical

        let h = UIStackView(arrangedSubviews: [artworkView, v])
        h.translatesAutoresizingMaskIntoConstraints = false
        h.spacing = UIStackView.spacingUseSystem
        return h
    }()

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        bootstrap()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(image: UIImage,
                   artist: String,
                   title: String,
                   songID: String) {
        self.songID = songID

        titleLabel.text = title
        artistLabel.text = artist
        artworkView.image = image
    }
}

extension CurrentSongView: ViewBootstrappable {
    func configureViews() {
        artworkView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        artworkView.heightAnchor.constraint(equalToConstant: 44).isActive = true

        widthAnchor.constraint(greaterThanOrEqualToConstant: 128).isActive = true
        heightAnchor.constraint(equalToConstant: 44).isActive = true

        addSubview(currentSongStack)
        currentSongStack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        currentSongStack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        currentSongStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        currentSongStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
