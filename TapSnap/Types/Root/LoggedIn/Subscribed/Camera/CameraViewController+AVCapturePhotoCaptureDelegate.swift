// CameraViewController+AVCapturePhotoCaptureDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import os.log
import Photos
import UIKit

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        switch error {
        case let .some(error): print("Error capturing photo: \(error)")
        case .none:
            guard let imageData = photo.fileDataRepresentation() else { return }

            let imageWithMetadata = imageData.updateMetadata(group: currentGroup?[GroupKey.name] as? String) ?? imageData

            guard let originalImage = UIImage(data: imageWithMetadata),
                let watermarkImage = Current.currentWatermarkSubject.value else {
                photoData = imageWithMetadata
                return
            }
            Current.cleanupSubject.send(.watermarked)

            UIGraphicsBeginImageContext(originalImage.size)
            let area = CGRect(origin: .zero, size: originalImage.size)

            originalImage.draw(in: area)

            let widthRatio = originalImage.size.width / watermarkImage.size.width

            let scaledWatermark = UIImage(cgImage: watermarkImage.cgImage!,
                                          scale: watermarkImage.scale / widthRatio,
                                          orientation: watermarkImage.imageOrientation)

            let xOffset = abs(originalImage.size.height - scaledWatermark.size.height) / 2
            let watermarkArea = CGRect(origin: CGPoint(x: 0, y: xOffset),
                                       size: scaledWatermark.size)

            scaledWatermark.draw(in: watermarkArea, blendMode: .normal, alpha: 1.0)

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
        switch error {
        case let .some(error): os_log("%@", log: .cloudKit, type: .error, error.localizedDescription); return
        case .none: break
        }

        guard let photoData = photoData else {
            os_log("%@", log: .fileManager, type: .error, "No photo data resource")
            return
        }

        let outputFileURL = URL.randomURL
        do {
            try photoData.write(to: outputFileURL)
        } catch {
            os_log("%@", log: .avFoundation, type: .error, error.localizedDescription)
            return
        }

        guard let currentGroup = self.currentGroup else {
            Current.cleanupSubject.send(.cleanUp(outputFileURL))
            return
        }
        CKContainer.default()
            .createNewMessage(for: currentGroup, with: .photo(outputFileURL)) { isSaved in
                guard UserDefaults.standard.bool(forKey: Current.k.settingAutoSave) else {
                    Current.cleanupSubject.send(.cleanUp(outputFileURL))
                    return
                }

                guard isSaved else { return }
                PHPhotoLibrary.requestAuthorization { status in
                    switch status {
                    case .authorized:
                        PHPhotoLibrary.shared().performChanges({
                            let options = PHAssetResourceCreationOptions()
                            let creationRequest = PHAssetCreationRequest.forAsset()
                            options.uniformTypeIdentifier = self.photoSettings.processedFileType.map { $0.rawValue }
                            creationRequest.addResource(with: .photo, data: photoData, options: options)

                        }, completionHandler: { _, error in
                            switch error {
                            case let .some(error):
                                os_log("%@", log: .photoLibrary, type: .error, error.localizedDescription)
                            default: break
                            }
                            Current.cleanupSubject.send(.cleanUp(outputFileURL))
                        })
                    default:
                        Current.cleanupSubject.send(.cleanUp(outputFileURL))
                    }
                }
            }
    }
}
