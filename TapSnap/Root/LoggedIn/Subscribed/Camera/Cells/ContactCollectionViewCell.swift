// ContactCollectionViewCell.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import UIKit

final class ContactCollectionViewCell: UICollectionViewCell {
    private lazy var contactImageView: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFill
        v.tintColor = .systemOrange
        v.clipsToBounds = true
        return v
    }()

    private lazy var contactTitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.4
        l.layer.shadowColor = UIColor.black.cgColor
        l.layer.shadowOffset = .zero
        l.layer.shadowRadius = 1
        l.layer.shadowOpacity = 1.0
        l.textAlignment = .center
        l.lineBreakMode = .byTruncatingTail
        return l
    }()

    private var record: CKRecord?

//    let zoom = UIPanGestureRecognizer(target: self, action: #selector(zoomCameraAction(_:)))

    // MARK: - Lifecycle

    override init(frame _: CGRect) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .secondarySystemBackground
        bootstrap()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(record: CKRecord) {
        self.record = record

        if let avatarAsset = record[GroupKey.avatar] as? CKAsset,
            let avatarURL = avatarAsset.fileURL,
            let avatarData = try? Data(contentsOf: avatarURL),
            let image = UIImage(data: avatarData) {
            contactImageView.image = image
        } else {
            contactImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        }

        if let title = record[GroupKey.name] as? String {
            let userCount = record[GroupKey.userCount] as? Int ?? 1
            let attributedString = NSMutableAttributedString()
            switch userCount {
            case 1 ... 50:
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = UIImage(systemName: "\(userCount).circle.fill",
                                                withConfiguration: UIImage.SymbolConfiguration(scale: .small))?
                    .withTintColor(.label, renderingMode: .alwaysTemplate)
                attributedString.append(NSAttributedString(attachment: imageAttachment))
            default: break
            }
            attributedString.append(NSAttributedString(string: "\(title)"))
            contactTitleLabel.attributedText = attributedString
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contactImageView.image = nil
    }

    // MARK: - Actions

    @objc func handleVideoAction(_ recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            Current.cloudKitSelectedGroupSubject.send(record)
            Current.mediaActionSubject.send(.captureVideoStart)
        case .ended:
            guard !(Current.mediaActionSubject.value == .captureVideoEnd) else { return }
            Current.mediaActionSubject.send(.captureVideoEnd)
        default: break
        }
    }

    @objc func handlePhotoAction(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            Current.cloudKitSelectedGroupSubject.send(record)
            Current.mediaActionSubject.send(.capturePhoto)
        default: break
        }
    }

    @objc private func zoomCameraAction(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            let velocity = recognizer.velocity(in: contentView)
            Current.zoomVeloictySubject.send(velocity)
        default: break
        }
    }
}

// MARK: - ViewBootstrappable

extension ContactCollectionViewCell: ViewBootstrappable {
    internal func configureViews() {
        contentView.addSubview(contactImageView)
        contactImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        contactImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        contactImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        contactImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true

        contentView.addSubview(contactTitleLabel)
        contactTitleLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
        contactTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4).isActive = true
        contactTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        contactTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }

    func configureGestureRecoginzers() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleVideoAction(_:)))
        longPress.delegate = self
        contentView.addGestureRecognizer(longPress)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePhotoAction(_:)))
        tap.delegate = self
        contentView.addGestureRecognizer(tap)

        let zoom = UIPanGestureRecognizer(target: self, action: #selector(zoomCameraAction(_:)))
        zoom.delegate = self
        contentView.addGestureRecognizer(zoom)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ContactCollectionViewCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        true
    }
}
