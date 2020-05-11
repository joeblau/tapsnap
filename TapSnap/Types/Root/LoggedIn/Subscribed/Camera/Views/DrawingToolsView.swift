// DrawingToolsView.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

final class DrawingToolsView: UIView {
    private let intrinsicHeight: CGFloat
    private let colorButtons = [UIColor.white,
                                UIColor.systemRed,
                                UIColor.systemOrange,
                                UIColor.systemYellow,
                                UIColor.systemGreen,
                                UIColor.systemBlue]
        .enumerated()
        .map { (offset: Int, color: UIColor) -> UIButton in
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.layer.cornerRadius = 20
            button.backgroundColor = color
            button.tag = offset
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            return button
        }

    lazy var colorPickerStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: colorButtons)
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.distribution = .equalSpacing
        return sv
    }()

    lazy var selected: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 26
        v.layer.borderWidth = 3
        v.layer.borderColor = UIColor.white.cgColor
        v.widthAnchor.constraint(equalToConstant: 52).isActive = true
        v.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return v
    }()

    init(height: CGFloat) {
        intrinsicHeight = height - 48.0
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        bootstrap()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_: CGRect) {
        selected.center = colorButtons.first?.center ?? .zero
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIWindow().screen.bounds.width,
               height: intrinsicHeight)
    }

    // MARK: - Actions

    @objc private func selectColorAction(sender: UIButton) {
        guard let color = sender.backgroundColor else {
            return
        }

        Current.drawingColorSubject.send(color)
        UIView.animate(withDuration: 0.3) {
            self.selected.center = sender.center
        }
    }
}

// MARK: - ViewBootstrappable

extension DrawingToolsView: ViewBootstrappable {
    internal func configureButtonTargets() {
        colorButtons.forEach { button in
            button.addTarget(self, action: #selector(selectColorAction), for: .touchUpInside)
        }
    }

    internal func configureViews() {
        addSubview(colorPickerStackView)
        colorPickerStackView.addSubview(selected)

        NSLayoutConstraint.activate([
            colorPickerStackView.topAnchor.constraint(equalTo: topAnchor, constant: 32),
            colorPickerStackView.heightAnchor.constraint(equalToConstant: 40),
            colorPickerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            colorPickerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }
}
