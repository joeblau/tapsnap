//
//  ContactEditorView.swift
//  Dolo
//
//  Created by Joe Blau on 2/2/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

class ContactEditorView: UIView {

    let editButton = UIButton(type: .system)
    let searchButton = UIButton(type: .system)
    let contactPageControl = UIPageControl()
    let contactEditorStackView: UIStackView
    
    init() {
        
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setTitle("Edit", for: .normal)
        editButton.tintColor = .label
        
        contactPageControl.numberOfPages = 4
        
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.tintColor = .label
        
        contactEditorStackView = UIStackView(arrangedSubviews: [editButton, contactPageControl, searchButton])
        contactEditorStackView.translatesAutoresizingMaskIntoConstraints = false
        contactEditorStackView.distribution = .equalSpacing
        
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        
        do {
            configureViews()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Views
    
    private func configureViews() {
        addSubview(contactEditorStackView)
        contactEditorStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contactEditorStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contactEditorStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        contactEditorStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
    }
    
}
