//
//  CloudKitManager+UICloudSharingControllerDelegate.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/16/20.
//

import UIKit
import CloudKit
import os.log

extension CloudKitManager: UICloudSharingControllerDelegate {
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
         os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        "New Tapsnap Group"
    }
    
    func itemThumbnailData(for csc: UICloudSharingController) -> Data? {
        UIImage(systemName: "video.fill")?.pngData()
    }
}
