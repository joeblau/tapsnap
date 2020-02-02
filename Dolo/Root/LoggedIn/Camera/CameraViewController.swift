//
//  CameraViewController.swift
//  Dolo
//
//  Created by Joe Blau on 2/1/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {

    let itemsInSection = [8, 8, 8, 4]
    let preview = CameraPreviewView()
    let contactsCollectionView = ContactsCollectionView()
    let contactEditorView = ContactEditorView()
    
    init() {
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactsCollectionView.register(ContactCollectionViewCell.self,
                                             forCellWithReuseIdentifier: ContactCollectionViewCell.id)
        contactsCollectionView.isPagingEnabled = true
        contactsCollectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.addSubview(contactEditorView)
        contactEditorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        contactEditorView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contactEditorView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contactEditorView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(contactsCollectionView)
        contactsCollectionView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        contactsCollectionView.bottomAnchor.constraint(equalTo: contactEditorView.topAnchor).isActive = true
        contactsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contactsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.addSubview(preview)
        preview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        preview.bottomAnchor.constraint(equalTo: contactsCollectionView.topAnchor).isActive = true
        preview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        preview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    // MARK: - Actions
    
    @objc func editContacts() {
        
    }
    
    @objc func searchContacts() {
        
    }
}
