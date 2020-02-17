// CameraViewController+UICollectionViewDataSource.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

extension CameraViewController: UICollectionViewDataSource {

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        itemsInSection[section]
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    }
}
