//
//  MenuViewController.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/7/20.
//

import UIKit



class MenuViewController: UIViewController {

    let menuSections: [SectionItem] = [
        SectionItem(menuItems: [
            MenuItem(systemName: "clock", titleText: "Activity"),
            MenuItem(systemName: "calendar", titleText: "Sent Today"),
            MenuItem(systemName: "heart", titleText: "Saved Taps")
            ]
        ),
        SectionItem(menuItems: [
            MenuItem(systemName: "paperplane", titleText: "Invite A Friend"),
            MenuItem(systemName: "person", titleText: "My Friends"),
            MenuItem(systemName: "person.2", titleText: "My Groups")
            ]
        ),
        SectionItem(menuItems: [
            MenuItem(systemName: "person.crop.square", titleText: "Profile"),
            MenuItem(systemName: "questionmark", titleText: "Help"),
            MenuItem(systemName: "gear", titleText: "Settings")
            ]
        )
    ]
    
    lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .insetGrouped)
        t.register(MenuCellTableViewCell.self, forCellReuseIdentifier: MenuCellTableViewCell.id)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.dataSource = self
        return t
    }()
    
    lazy var closeButton: UIBarButtonItem = {
       let b =  UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                          landscapeImagePhone: UIImage(systemName: "xmark"),
                                          style: .done,
                                          target: self,
                                          action: #selector(closeMenuAction))
        b.tintColor = .white
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Menu"
        navigationItem.leftBarButtonItem = closeButton
        
        do {
            configureViews()
        }
    }
    
    // MARK: - Configure Views
    
    private func configureViews() {
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    // MARK: - Actoins
    
    @objc func closeMenuAction() {
        self.dismiss(animated: true, completion: nil)
    }

}
