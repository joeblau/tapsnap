// CameraViewController+UICollectionViewDataSource.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

extension CameraViewController: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int { 2 }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return itemsInSection[section]
        case 1: return 1
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactCollectionViewCell.id,
                                                                for: indexPath) as? ContactCollectionViewCell else {
                fatalError("Invalid cell type")
            }

            let url = URL(string: "https://i.pravatar.cc/150?img=\(indexPath.row)")!
            URLSession.shared.dataTaskPublisher(for: url)
                .map { UIImage(data: $0.data)! }
                .eraseToAnyPublisher()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                    //                print(completion)
                            }) { image in
                    cell.configure(image: image, title: "Joe", groupSize: indexPath.row)
                }
                .store(in: &cancellables)

            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactAddCollectionViewCell.id,
                                                                for: indexPath) as? ContactAddCollectionViewCell else {
                fatalError("Invalid cell type")
            }
            return cell
        default: fatalError("Invalid section")
        }
    }
}
