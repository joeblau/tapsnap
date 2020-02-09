//
//  CameraViewController+AVCapturePhotoCaptureDelegate.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/9/20.
//

import UIKit
import Photos

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {        
        if let error = error {
            print("Error capturing photo: \(error)")
        } else {
            photoData = photo.fileDataRepresentation()
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
//        if let error = error {
//            print("Error capturing photo: \(error)")
//            didFinish()
//            return
//        }
//
        guard let photoData = photoData else {
            print("No photo data resource")
            return
        }
//
//        PHPhotoLibrary.requestAuthorization { status in
//            if status == .authorized {
//                PHPhotoLibrary.shared().performChanges({
//                    let options = PHAssetResourceCreationOptions()
//                    let creationRequest = PHAssetCreationRequest.forAsset()
//                    options.uniformTypeIdentifier = self.requestedPhotoSettings.processedFileType.map { $0.rawValue }
//                    creationRequest.addResource(with: .photo, data: photoData, options: options)
//
//                    if let livePhotoCompanionMovieURL = self.livePhotoCompanionMovieURL {
//                        let livePhotoCompanionMovieFileOptions = PHAssetResourceCreationOptions()
//                        livePhotoCompanionMovieFileOptions.shouldMoveFile = true
//                        creationRequest.addResource(with: .pairedVideo,
//                                                    fileURL: livePhotoCompanionMovieURL,
//                                                    options: livePhotoCompanionMovieFileOptions)
//                    }
//
//                    // Save Portrait Effects Matte to Photos Library only if it was generated
//                    if let portraitEffectsMatteData = self.portraitEffectsMatteData {
//                        let creationRequest = PHAssetCreationRequest.forAsset()
//                        creationRequest.addResource(with: .photo,
//                                                    data: portraitEffectsMatteData,
//                                                    options: nil)
//                    }
//                    // Save Portrait Effects Matte to Photos Library only if it was generated
//                    for semanticSegmentationMatteData in self.semanticSegmentationMatteDataArray {
//                        let creationRequest = PHAssetCreationRequest.forAsset()
//                        creationRequest.addResource(with: .photo,
//                                                    data: semanticSegmentationMatteData,
//                                                    options: nil)
//                    }
//
//                }, completionHandler: { _, error in
//                    if let error = error {
//                        print("Error occurred while saving photo to photo library: \(error)")
//                    }
//
//                    self.didFinish()
//                }
//                )
//            } else {
//                self.didFinish()
//            }
//        }
    }
}
