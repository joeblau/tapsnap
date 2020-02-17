// CloudKitManager+UICloudSharingControllerDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import os.log
import UIKit

extension CloudKitManager: UICloudSharingControllerDelegate {
    func cloudSharingController(_: UICloudSharingController, failedToSaveShareWithError error: Error) {
        os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
    }

    func itemTitle(for _: UICloudSharingController) -> String? {
        "Join Tapsnap Group"
    }

    func itemThumbnailData(for _: UICloudSharingController) -> Data? {
        UIImage(systemName: "video.fill")?.pngData()
    }
}
