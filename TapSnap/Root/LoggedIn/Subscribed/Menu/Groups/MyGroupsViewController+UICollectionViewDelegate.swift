// MyGroupsViewController+UICollectionViewDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import UIKit
import os.log

extension MyGroupsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MyGroupCollectionViewCell,
            let record = cell.record else {
            fatalError("Invalid cell type")
        }
        CKContainer.default().manage(group: record, sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil) { suggestedActions -> UIMenu? in
                                            
                                            let cell = collectionView.cellForItem(at: indexPath) as? MyGroupCollectionViewCell
                                            switch cell {
                                            case let .some(groupCell):
                                                Current.cloudKitSelectedGroupSubject.send(groupCell.record)
                                                return self.buildContextMenu()
                                            case .none: return nil
                                            }
        }
    }
    
    private func buildContextMenu() -> UIMenu {
        
        guard let selectedGroup = Current.cloudKitSelectedGroupSubject.value else { return UIMenu(title: "") }
        
        let rename = UIAction(title: "Rename", image: UIImage(systemName: "square.and.pencil")) { action in
            
            let alert = RenameGroupViewController(title: "Rename Group", message: nil, preferredStyle: .alert)
            alert.groupName = selectedGroup[GroupKey.name] as? String ?? "-"
            self.present(alert, animated: true)
            
        }

        let image = UIAction(title: "Image", image: UIImage(systemName: "photo")) { action in
            let imagePickerViewController = UIImagePickerController()
            imagePickerViewController.delegate = self
            self.present(imagePickerViewController, animated: true, completion: nil)
        }
        
        let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
            // Share
        }

        let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
            let alert = DeleteGroupViewController(title: "Delete Group", message: "Type the word \"CONFIRM\" in caps to confirm group deletion", preferredStyle: .alert)
            self.present(alert, animated: true)
        }
        
        let edit = UIMenu(title: "", options: .displayInline, children: [delete])
        
        return UIMenu(title: "", children: [rename, image, share, edit])
    }
}


extension MyGroupsViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ imagePickerController: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage,
            let smallImage = image.scale(to: 512.0),
            let selectedGroup = Current.cloudKitSelectedGroupSubject.value else { return }
        
        let outputFileURL = URL.randomURL
        do {
            try smallImage.pngData()?.write(to: outputFileURL)
        } catch {
            os_log("%@", log: .avFoundation, type: .error, error.localizedDescription)
            imagePickerController.dismiss(animated: true, completion: nil)
            return
        }
        
        CKContainer.default().updateGroup(recordID: selectedGroup.recordID, image: outputFileURL) { saved in
            DispatchQueue.main.async {
                imagePickerController.dismiss(animated: true, completion: nil)
            }
        }
    }
}
