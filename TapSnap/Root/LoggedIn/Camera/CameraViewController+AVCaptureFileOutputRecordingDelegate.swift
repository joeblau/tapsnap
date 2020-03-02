// CameraViewController+AVCaptureFileOutputRecordingDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import AVFoundation
import Photos
import UIKit
import CloudKit

private let kMediaContentTimeValue: Int64 = 1
private let kMediaContentTimeScale: Int32 = 30

enum WatermarkError: Error {
    case unknown
    case extractTrack
    case exportSession
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from _: [AVCaptureConnection], error: Error?) {
        switch Current.currentWatermarkSubject.value {
        case let .some(watermark):
            let urlAsset = AVURLAsset(url: outputFileURL)
            addWatermark(movie: urlAsset, image: watermark) { result in
                self.cleanUp(url: outputFileURL)
                switch result {
                case let .success(watermarURL):
                    guard let currentGroup = self.currentGroup else { return }
                    CKContainer.default()
                        .createNewMessage(for: currentGroup, with: watermarURL) { _ in
                            guard UserDefaults.standard.bool(forKey: Current.k.autoSave) else { return }
                            PHPhotoLibrary.requestAuthorization { status in
                                switch status {
                                case .authorized:
                                    PHPhotoLibrary.shared().performChanges({
                                        let options = PHAssetResourceCreationOptions()
                                        options.shouldMoveFile = true
                                        let creationRequest = PHAssetCreationRequest.forAsset()
                                        creationRequest.addResource(with: .video, fileURL: watermarURL, options: options)
                                    }, completionHandler: { success, error in
                                        if !success {
                                            print("AVCam couldn't save the movie to your photo library: \(String(describing: error))")
                                            self.cleanUp(url: watermarURL)
                                        }
                                    })
                                default:
                                    self.cleanUp(url: watermarURL)
                                }
                            }
                    }
                    
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        case .none:
            switch error {
            case let .some(error):
                print("Movie file finishing error: \(String(describing: error))")
                cleanUp(url: outputFileURL)
            case .none:
                guard let currentGroup = self.currentGroup else { return }
                CKContainer.default()
                    .createNewMessage(for: currentGroup, with: outputFileURL) { _ in
                        guard UserDefaults.standard.bool(forKey: Current.k.autoSave) else { return }
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
                                        self.cleanUp(url: outputFileURL)
                                    }
                                })
                            default:
                                self.cleanUp(url: outputFileURL)
                            }
                        }
                }
            }
        }
    }
    
    func cleanUp(url: URL) {
        let path = url.path
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                print("Could not remove file at url: \(url)")
            }
        }
        
        if let currentBackgroundRecordingID = backgroundRecordingID {
            backgroundRecordingID = UIBackgroundTaskIdentifier.invalid
            
            if currentBackgroundRecordingID != UIBackgroundTaskIdentifier.invalid {
                UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
            }
        }
    }
    
    func addWatermark(movie: AVURLAsset,
                      image: UIImage,
                      completion: @escaping (Result<URL, Error>) -> Void) {
        let finalComposition = AVMutableComposition()
        let timeRange = CMTimeRangeMake(start: .zero, duration: movie.duration)
        
        guard let clipVideoTrack = movie.tracks(withMediaType: .video).first,
            let clipAudioTrack = movie.tracks(withMediaType: .audio).first else {
                completion(Result.failure(WatermarkError.extractTrack))
                return
        }
        
        let compositionVideoTrack = finalComposition.addMutableTrack(withMediaType: .video,
                                                                     preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try compositionVideoTrack?.insertTimeRange(timeRange, of: clipVideoTrack, at: .zero)
        } catch { completion(Result.failure(error)) }
        
        let compositionAudioTrack = finalComposition.addMutableTrack(withMediaType: .audio,
                                                                     preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try compositionAudioTrack?.insertTimeRange(timeRange, of: clipAudioTrack, at: .zero)
        } catch { completion(Result.failure(error)) }
        
        compositionVideoTrack?.preferredTransform = clipVideoTrack.preferredTransform
        
        let videoSize = compositionVideoTrack?.size ?? CGSize.zero
        
        let overlayLayer = CALayer()
        overlayLayer.frame = CGRect(origin: .zero, size: videoSize)
        overlayLayer.masksToBounds = true
        
        let widthRatio = videoSize.width / image.size.width
        let watermarkSize = CGSize(width: videoSize.width,
                                   height: image.size.height * widthRatio)
        
        let yOffset = (videoSize.height - watermarkSize.height) / 2.0
        
        let watermarkLayer = CALayer()
        watermarkLayer.contents = image.cgImage
        watermarkLayer.frame = CGRect(origin: CGPoint(x: 0, y: yOffset),
                                      size: watermarkSize)
        overlayLayer.addSublayer(watermarkLayer)
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(origin: .zero, size: videoSize)
        videoLayer.frame = CGRect(origin: .zero, size: videoSize)
        
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(overlayLayer)
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(value: kMediaContentTimeValue,
                                                    timescale: kMediaContentTimeScale)
        videoComposition.renderSize = videoSize
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer,
                                                                             in: parentLayer)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: .zero, duration: finalComposition.duration)
        
        guard let videoTrack = finalComposition.tracks(withMediaType: .video).first else {
            completion(Result.failure(WatermarkError.extractTrack))
            return
        }
        
        let offset = CGPoint(x: videoSize.width, y: 0)
        let angle = Double.pi / 2
        
        let translation = CGAffineTransform(translationX: offset.x, y: offset.y)
        let rotation = translation.rotated(by: CGFloat(angle))
        
        let layerInstrution = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        layerInstrution.setTransform(rotation, at: .zero)
        instruction.layerInstructions = [layerInstrution]
        videoComposition.instructions = [instruction]

        let outputFileURL = FileManager.default
                    .temporaryDirectory
                    .appendingPathComponent(NSUUID().uuidString)
                    .appendingPathExtension("mov")
        
        guard let exportSession = AVAssetExportSession(asset: finalComposition,
                                                       presetName: AVAssetExportPresetHEVCHighestQuality) else {
                                                        return
        }
        exportSession.videoComposition = videoComposition
        exportSession.outputURL = outputFileURL
        exportSession.outputFileType = .mov
        exportSession.exportAsynchronously(completionHandler: {
            switch exportSession.status {
            case .completed:
                completion(Result.success(outputFileURL))
            default:
                completion(Result.failure(WatermarkError.unknown))
            }
        })
    }
}
