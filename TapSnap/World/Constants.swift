// Constants.swift
// Copyright (c) 2020 Tapsnap, LLC

import Foundation

struct Constants {
    let currentUserName = "current_user_name"
    let currentUserAvatar = "current_user_avatar"
    
    let privateEncryptionKey = "private_encryption_key"
    let publicEncryptionKey = "public_encryption_key"
    let privateSigningKey = "private_signing_key"
    let publicSigningKey = "public_signing_key"

    let messageSubscriptionID = "message_subscription_cloudKit_identifier"
    let userAccount = "current_user_cloudKit_account"

    let settingAutoSave = "automatically_save_sent_taps_to_camera_roll"
    let isVisualizerHidden = "hidden_touch_visuzlier_during_gestures"
    let subscriptionCached = "subscription_cached"

    let creatorReference = "cloudkit_creator_reference"
    let creatorPredicate = "cloudkit_creator_predicate"
    let recipientPredicate = "cloudkit_recipient_predicate"
}
