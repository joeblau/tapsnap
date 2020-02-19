// CameraViewController+AVCapturePhotoCaptureDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import Photos
import UIKit

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        switch error {
        case let .some(error): print("Error capturing photo: \(error)")
        case .none:
            guard let imageData = photo.fileDataRepresentation() else { return }

            let imageWithMetadata = imageData.updateMetadata() ?? imageData

            guard let originalImage = UIImage(data: imageWithMetadata),
                let watermarkImage = Current.currentWatermarkSubject.value else {
                photoData = imageWithMetadata
                return
            }

            UIGraphicsBeginImageContext(originalImage.size)
            let area = CGRect(origin: .zero, size: originalImage.size)

            originalImage.draw(in: area)

            let widthRatio = originalImage.size.width / watermarkImage.size.width
            let watermarkSize = CGSize(width: originalImage.size.width,
                                       height: watermarkImage.size.height * widthRatio)

            let yOffset = (originalImage.size.height - watermarkSize.height) / 2
            let watermarkArea = CGRect(origin: CGPoint(x: 0, y: yOffset),
                                       size: watermarkSize)
            watermarkImage.draw(in: watermarkArea, blendMode: .normal, alpha: 1.0)

            let layeredImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            let c = CIContext()
            guard let layeredUIImage = layeredImage,
                let finalCIImage = CIImage(image: layeredUIImage),
                let colorSpace = c.workingColorSpace else { return }

            photoData = c.heifRepresentation(of: finalCIImage,
                                             format: .RGBA8,
                                             colorSpace: colorSpace,
                                             options: [:])
        }
    }

    func photoOutput(_: AVCapturePhotoOutput, didFinishCaptureFor _: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }

        guard let photoData = photoData else {
            print("No photo data resource")
            return
        }

        guard UserDefaults.standard.bool(forKey: Current.k.autoSave) else { return }
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    options.uniformTypeIdentifier = self.photoSettings.processedFileType.map { $0.rawValue }
                    creationRequest.addResource(with: .photo, data: photoData, options: options)

                }, completionHandler: { _, error in
                    if let error = error {
                        print("Error occurred while saving photo to photo library: \(error)")
                    }
                })
            }
        }
    }
}
