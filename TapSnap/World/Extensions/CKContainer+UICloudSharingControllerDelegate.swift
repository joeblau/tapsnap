// CKContainer+UICloudSharingControllerDelegate.swift
// Copyright (c) 2020 Tapsnap, LLC

import CloudKit
import os.log
import UIKit

extension CKContainer: UICloudSharingControllerDelegate {
    public func cloudSharingController(_: UICloudSharingController, failedToSaveShareWithError error: Error) {
        os_log("%@", log: .cloudKit, type: .error, error.localizedDescription)
    }

    public func itemTitle(for _: UICloudSharingController) -> String? {
        "Join Tapsnap Group"
    }

    public func itemThumbnailData(for _: UICloudSharingController) -> Data? {
        UIImage(systemName: "video.fill")?.pngData()
    }
}
