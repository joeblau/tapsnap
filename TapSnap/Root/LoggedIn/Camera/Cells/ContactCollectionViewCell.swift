// ContactCollectionViewCell.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit
import CloudKit

final class ContactCollectionViewCell: UICollectionViewCell {
    private lazy var contactImageView: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.tintColor = .systemRed
        v.contentMode = .center
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

    func configure(image: UIImage,
                   title: String,
                   record: CKRecord?,
                   groupSize: Int = 0) {
        contactImageView.image = image

        let attributedString = NSMutableAttributedString()
        switch groupSize {
        case 1 ... 50:
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "\(groupSize).circle.fill",
                                            withConfiguration: UIImage.SymbolConfiguration(scale: .small))
            imageAttachment.image?.withTintColor(.white, renderingMode: .alwaysOriginal)
            attributedString.append(NSAttributedString(attachment: imageAttachment))
        default: break
        }
        attributedString.append(NSAttributedString(string: "\(title)"))
        contactTitleLabel.attributedText = attributedString
        self.record = record
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contactImageView.image = nil
    }

    // MARK: - Resuse Identifier

    static let id = String(describing: ContactCollectionViewCell.self)

    // MARK: - Actions

    @objc func handleVideoAction(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            Current.cloudKitSelectedGroupSubject.send(self.record)
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
            Current.cloudKitSelectedGroupSubject.send(self.record)
            Current.mediaActionSubject.send(.capturePhoto)
        default: break
        }
    }

//    @objc private func zoomCameraAction(_ recognizer: UIPanGestureRecognizer) {
//        switch recognizer.state {
//        case .changed:
//            let velocity = recognizer.velocity(in: contentView)
//            Current.zoomVeloictySubject.send(velocity)
//        default: break
//        }
//    }
}

// MARK: - ViewBootstrappable

extension ContactCollectionViewCell: ViewBootstrappable, UIGestureRecognizerDelegate {
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
        contentView.addGestureRecognizer(longPress)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePhotoAction(_:)))
        contentView.addGestureRecognizer(tap)

//        let zoom = UIPanGestureRecognizer(target: self, action: #selector(zoomCameraAction(_:)))
//        contentView.addGestureRecognizer(zoom)
    }
}
