// EmptyDataView.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

class EmptyDataView: UIView {
    var emojiXConstriant: NSLayoutConstraint?
    var shadowWidthConstraint: NSLayoutConstraint?
    var shadowHeightConstraint: NSLayoutConstraint?

    private lazy var emoji: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "😢"
        l.textAlignment = .center
        l.backgroundColor = .clear
        l.font = UIFont.systemFont(ofSize: 60)
        return l
    }()

    private lazy var title: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 0
        l.text = L10n.titleNoFriends
        l.textAlignment = .center
        l.textColor = .label
        return l
    }()

    private lazy var shadow: UIImageView = {
        let image = UIImage(systemName: "circle.fill")
        let v = UIImageView(image: image)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.tintColor = .secondarySystemBackground
        return v
    }()

    override init(frame _: CGRect) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        bootstrap()
    }

    func startAnimation() {
        DispatchQueue.main.async {
            self.emojiXConstriant?.constant = -60
            self.shadowWidthConstraint?.constant = 26
            self.shadowHeightConstraint?.constant = 10

            UIView.animate(withDuration: 1.0,
                           delay: 0.0,
                           options: [.autoreverse, .repeat],
                           animations: {
                               self.layoutIfNeeded()
            }, completion: nil)
        }
    }

    func stopAnimation() {
        emoji.layer.removeAllAnimations()
        shadow.layer.removeAllAnimations()

        emojiXConstriant?.constant = -50.0
        shadowWidthConstraint?.constant = 30.0
        shadowHeightConstraint?.constant = 12.0
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EmptyDataView: ViewBootstrappable {
    func configureViews() {
        widthAnchor.constraint(equalToConstant: 300).isActive = true
        heightAnchor.constraint(equalToConstant: 300).isActive = true

        addSubview(emoji)
        emoji.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        emojiXConstriant = emoji.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50)
        emojiXConstriant?.isActive = true
        emoji.heightAnchor.constraint(greaterThanOrEqualToConstant: 10.0).isActive = true
        emoji.widthAnchor.constraint(greaterThanOrEqualToConstant: 10.0).isActive = true

        addSubview(shadow)
        shadow.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        shadow.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        shadowWidthConstraint = shadow.widthAnchor.constraint(equalToConstant: 30.0)
        shadowWidthConstraint?.isActive = true
        shadowHeightConstraint = shadow.heightAnchor.constraint(equalToConstant: 12.0)
        shadowHeightConstraint?.isActive = true

        addSubview(title)
        title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        title.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 50).isActive = true
        title.heightAnchor.constraint(greaterThanOrEqualToConstant: 10.0).isActive = true
        title.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
}
