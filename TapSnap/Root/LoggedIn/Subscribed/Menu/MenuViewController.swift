// MenuViewController.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import os.log
import UIKit

final class MenuViewController: UIViewController {
    let menuSections: [SectionItem] = [
        SectionItem(menuItems: [
            MenuItem(systemName: "person.crop.square", titleText: "Profile"),
        ]),
//        SectionItem(menuItems: [
//            MenuItem(systemName: "clock", titleText: "Activity"),
//            MenuItem(systemName: "calendar", titleText: "Sent Today"),
//            MenuItem(systemName: "heart", titleText: "Saved"),
//        ]),
        SectionItem(menuItems: [
//            MenuItem(systemName: "paperplane", titleText: "Invite A Friend"),
            MenuItem(systemName: "person.2", titleText: "My Groups"),
        ]),
        SectionItem(menuItems: [
            MenuItem(systemName: "square.and.arrow.down", titleText: "Auto-Save", subtitleText: "Automatically save sent taps"),
            MenuItem(systemName: "hand.draw", titleText: "Visualizer", subtitleText: "Visualize touches on screen"),
        ]),
        SectionItem(menuItems: [
            MenuItem(systemName: "gear", titleText: "Settings", subtitleText: "iOS app settings"),
        ]),
        SectionItem(header: "Security",
                    menuItems: [
                        MenuItem(systemName: "lock.shield", titleText: "Reset Keys", subtitleText: "Reset public and private keys"),
                    ]),
    ]

    lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .insetGrouped)
        t.register(MenuCellTableViewCell.self, forCellReuseIdentifier: MenuCellTableViewCell.id)
        t.register(ToggleTableViewCell.self, forCellReuseIdentifier: ToggleTableViewCell.id)
        t.register(AvatarNameTableViewCell.self, forCellReuseIdentifier: AvatarNameTableViewCell.id)
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
    func imagePickerController(_ imagePickerController: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage,
            let smallImage = image.scale(to: 256.0) else { return }

        let outputFileURL = URL.randomURL
        do {
            try smallImage.pngData()?.write(to: outputFileURL)
        } catch {
            os_log("%@", log: .avFoundation, type: .error, error.localizedDescription)
            imagePickerController.dismiss(animated: true, completion: nil)
            return
        }

        CKContainer.default().updateUser(image: outputFileURL, completion: { [unowned self] saved in
            DispatchQueue.main.async {
                UserDefaults.standard.set(smallImage.pngData(), forKey: Current.k.currentUserAvatar)
                switch saved {
                case true: self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                case false: break
                }
                imagePickerController.dismiss(animated: true, completion: nil)
            }
        })
    }
}
