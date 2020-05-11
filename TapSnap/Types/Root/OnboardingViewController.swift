// OnboardingViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

final class OnboardingViewController: UIViewController {
    private var valueAction: (_ controller: OnboardingViewController) -> Void = { _ in }

    lazy var valueDescription: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 0
        l.font = UIFont.preferredFont(forTextStyle: .title2)
        l.textAlignment = .center
        return l
    }()

    lazy var valueError: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 0
        l.textColor = .systemRed
        l.textAlignment = .center
        return l
    }()

    lazy var valueImage: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.translatesAutoresizingMaskIntoConstraints = false
        v.tintColor = .label
        return v
    }()

    lazy var valueButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = .systemBlue
        b.setTitleColor(.label, for: .normal)
        b.layer.cornerRadius = 12
        b.addTarget(self, action: #selector(valueButtonAction), for: .touchUpInside)
        return b
    }()

    lazy var stackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [valueImage, valueDescription, UIView(), valueError, valueButton])
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .vertical
        return v
    }()

    init(title: String,
         image: UIImage?,
         description: String,
         buttonText: String,
         valueAction: @escaping (_ controller: OnboardingViewController) -> Void) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        valueImage.image = image
        valueDescription.text = description

        valueButton.setTitle(buttonText, for: .normal)
        self.valueAction = valueAction
        navigationItem.hidesBackButton = true
    }

    func show(error: String? = nil) {
        DispatchQueue.main.async {
            self.valueError.text = error
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        bootstrap()
    }

    @objc func valueButtonAction() {
        valueAction(self)
    }
}

extension OnboardingViewController: ViewBootstrappable {
    func configureViews() {
        view.addSubview(stackView)

        valueImage.heightAnchor.constraint(equalToConstant: 64).isActive = true
        valueImage.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true

        valueDescription.heightAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true

        valueButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        valueButton.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true

        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
    }
}
