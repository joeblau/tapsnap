// CameraViewController+AVCaptureFileOutputRecordingDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import AVFoundation
import Photos
import UIKit

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from _: [AVCaptureConnection], error: Error?) {
        func cleanUp() {
            let path = outputFileURL.path
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    print("Could not remove file at url: \(outputFileURL)")
                }
            }

            if let currentBackgroundRecordingID = backgroundRecordingID {
                backgroundRecordingID = UIBackgroundTaskIdentifier.invalid

                if currentBackgroundRecordingID != UIBackgroundTaskIdentifier.invalid {
                    UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
                }
            }
        }

        switch error {
        case let .some(error):
            print("Movie file finishing error: \(String(describing: error))")
            cleanUp()
        case .none:
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    PHPhotoLibrary.shared().performChanges({
                        let options = PHAssetResourceCreationOptions()
                        options.shouldMoveFile = true
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
                    }, completionHandler: { success, error in
                        if !success {
                            print("AVCam couldn't save the movie to your photo library: \(String(describing: error))")
                            cleanUp()
                        }
                    })
                default:
                    cleanUp()
                }
            }
        }
    }
}
