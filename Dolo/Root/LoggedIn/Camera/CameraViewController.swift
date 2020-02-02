//
//  CameraViewController.swift
//  Dolo
//
//  Created by Joe Blau on 2/1/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {

    let preview = CameraPreviewView()
    let contacts = UIView()
    
    init() {
        contacts.translatesAutoresizingMaskIntoConstraints = false
        contacts.backgroundColor = .green
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews(
        )
        view.addSubview(contacts)
        contacts.heightAnchor.constraint(equalToConstant: view.safeAreaInsets.bottom +  360).isActive = true
        contacts.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contacts.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contacts.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        view.addSubview(preview)
        preview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        preview.bottomAnchor.constraint(equalTo: contacts.topAnchor).isActive = true
        preview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        preview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}
