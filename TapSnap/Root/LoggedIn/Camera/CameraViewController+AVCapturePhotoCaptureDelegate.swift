// CameraViewController+AVCapturePhotoCaptureDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import Photos
import UIKit

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
        } else {
            photoData = photo.fileDataRepresentation()
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
