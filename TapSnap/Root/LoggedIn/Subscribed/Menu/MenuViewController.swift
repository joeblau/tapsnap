// MenuViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

final class MenuViewController: UIViewController {
    let menuSections: [SectionItem] = [
        SectionItem(menuItems: [
            MenuItem(systemName: "person.crop.square", titleText: "Profile"),
        ]),
        SectionItem(menuItems: [
            MenuItem(systemName: "clock", titleText: "Activity"),
            MenuItem(systemName: "calendar", titleText: "Sent Today"),
            MenuItem(systemName: "heart", titleText: "Saved"),
        ]),
        SectionItem(menuItems: [
            MenuItem(systemName: "paperplane", titleText: "Invite A Friend"),
            MenuItem(systemName: "person.2", titleText: "My Groups"),
        ]),
        SectionItem(menuItems: [
            MenuItem(systemName: "square.and.arrow.down", titleText: "Auto-Save", subtitleText: "Automatically save sent taps"),
            MenuItem(systemName: "hand.draw", titleText: "Visualizer", subtitleText: "Visualize touches on screen (requires app restart)"),
        ]),
        SectionItem(menuItems: [
            MenuItem(systemName: "gear", titleText: "Settings"),
        ]),
    ]

    lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .insetGrouped)
        t.register(MenuCellTableViewCell.self,
                   forCellReuseIdentifier: MenuCellTableViewCell.id)
        t.register(UITableViewCell.self,
                   forCellReuseIdentifier: UITableViewCell.id)
        t.register(AvatarNameTableViewCell.self,
                   forCellReuseIdentifier: AvatarNameTableViewCell.id)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.rowHeight = UITableView.automaticDimension
        t.estimatedRowHeight = 44.0
        t.dataSource = self
        t.delegate = self
        return t
    }()

    lazy var closeButton: UIBarButtonItem = {
        let b = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                landscapeImagePhone: UIImage(systemName: "xmark"),
                                style: .done,
                                target: self,
                                action: #selector(closeMenuAction))
        b.tintColor = .white
        return b
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Menu"
        navigationItem.leftBarButtonItem = closeButton
        configureViews()
    }

    // MARK: - Actions

    @objc func closeMenuAction() {
        dismiss(animated: true, completion: nil)
    }

    @objc func updateAvatar() {
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.delegate = self
        present(imagePickerViewController, animated: true, completion: nil)
    }
}

// MARK: - ViewBootstrappable

extension MenuViewController: ViewBootstrappable {
    internal func configureViews() {
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

extension MenuViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage,
            let _ = image.scale(to: 256.0) else { return }
    }
}
