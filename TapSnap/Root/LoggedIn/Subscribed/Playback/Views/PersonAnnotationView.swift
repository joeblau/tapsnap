// PersonAnnotationView.swift
// Copyright (c) 2020 Tapsnap, LLC

import MapKit
import UIKit

final class PersonAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        translatesAutoresizingMaskIntoConstraints = false
        contentMode = .scaleAspectFit
        layer.masksToBounds = true
        layer.cornerRadius = 24
        layer.borderColor = UIColor.label.cgColor
        layer.borderWidth = 3
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)

        widthAnchor.constraint(equalToConstant: 48).isActive = true
        heightAnchor.constraint(equalToConstant: 48).isActive = true

        backgroundColor = .systemBackground
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(image: UIImage) {
        self.image = image
    }

    // MARK: - Resuse Identifier

    static let id = String(describing: PersonAnnotationView.self)
}
