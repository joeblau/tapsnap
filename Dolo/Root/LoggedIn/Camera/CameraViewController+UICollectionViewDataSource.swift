//
//  CameraViewController+UIColl.swift
//  Dolo
//
//  Created by Joe Blau on 2/2/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

extension CameraViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return itemsInSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsInSection[section]
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactCollectionViewCell.id,
                                                      for: indexPath) as? ContactCollectionViewCell else {
                                                        fatalError("invalid cell converison")
        }
        
//        let url = URL(string: "https://i.pravatar.cc/150?img=\(indexPath.row)")!
//        URLSession.shared.dataTaskPublisher(for: url)
//            .map { UIImage(data: $0.data)! }
//            .eraseToAnyPublisher()
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
////                print(completion)
//            }) { image in
//                cell.configure(image: image)
//            }
//            .store(in: &self.cancellables)
        
        return cell
    }
}
