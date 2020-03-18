//
//  OnboardingViewController.swift
//  Tapsnap
//
//  Created by Joe Blau on 3/17/20.
//

import UIKit


final class OnboardingViewController: UIViewController {
    
    private var valueAction: () -> () = {}
    
    lazy var valueDescription: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 0
        l.font = UIFont.preferredFont(forTextStyle: .title2)
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
        let v = UIStackView(arrangedSubviews: [valueImage, valueDescription, UIView(), valueButton])
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .vertical
        return v
    }()
    
    init(title: String,
         image: UIImage?,
         description: String,
         buttonText: String,
         valueAction: @escaping () -> () ) {
        
        super.init(nibName: nil, bundle: nil)
        self.title = title
        self.valueImage.image = image
        self.valueDescription.text = description
        self.valueButton.setTitle(buttonText, for: .normal)
        self.valueAction = valueAction
        navigationItem.hidesBackButton = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        bootstrap()
    }
    
    @objc func valueButtonAction() {
        self.valueAction()
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
