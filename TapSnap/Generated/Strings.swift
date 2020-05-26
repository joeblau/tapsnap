// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {
  /// Tapsnap is a video and photo app and uses your camera to create videos and photos.
  internal static let bodyCameraUse = L10n.tr("Localizable", "body_camera_use")
  /// Type the word "CONFIRM" in caps to confirm group deletion
  internal static let bodyDeleteGroup = L10n.tr("Localizable", "body_delete_group")
  /// Tapsnap uses your iCloud Apple ID account as your account. You will not be able to use Tapsnap without an iCloud account.
  internal static let bodyIcloudUse = L10n.tr("Localizable", "body_icloud_use")
  /// Tapsnap can share your location with your taps.
  internal static let bodyLocationUse = L10n.tr("Localizable", "body_location_use")
  /// Tapsnap uses your microphone to record your voice and audio for your video taps.
  internal static let bodyMicrophoneUse = L10n.tr("Localizable", "body_microphone_use")
  /// Enter a name for your new group
  internal static let bodyNewGroup = L10n.tr("Localizable", "body_new_group")
  /// You are currently not connected to the Internet, please connect to cellular or Wi-Fi.
  internal static let bodyNoConnectivity = L10n.tr("Localizable", "body_no_connectivity")
  /// Tapsnap can alert you whenever new messages are available.
  internal static let bodyNotificationsUse = L10n.tr("Localizable", "body_notifications_use")
  /// Type "RESET KEYS" Reset public and private keys
  internal static let bodyResetKeys = L10n.tr("Localizable", "body_reset_keys")
  /// Deferred
  internal static let deferred = L10n.tr("Localizable", "deferred")
  /// Failed to locate stored key.
  internal static let errorKeystoreFailedToLocateStoredKey = L10n.tr("Localizable", "error_keystore_failed_to_locate_stored_key")
  /// Keychain read failed: %@
  internal static func errorKeystoreKeychainReadFailed(_ p1: String) -> String {
    return L10n.tr("Localizable", "error_keystore_keychain_read_failed", p1)
  }
  /// Unable to store item: %@
  internal static func errorKeystoreUnableToStore(_ p1: String) -> String {
    return L10n.tr("Localizable", "error_keystore_unable_to_store", p1)
  }
  /// Unexpected deletion error: %@
  internal static func errorKeystoreUnexpectedDeletion(_ p1: String) -> String {
    return L10n.tr("Localizable", "error_keystore_unexpected_deletion", p1)
  }
  /// No App Store receipt.
  internal static let errorNoAppStoreReceipt = L10n.tr("Localizable", "error_no_app_store_receipt")
  /// Failed
  internal static let failed = L10n.tr("Localizable", "failed")
  /// Key representation contains %d bytes.
  internal static func keyByteCount(_ p1: Int) -> String {
    return L10n.tr("Localizable", "key_byte_count", p1)
  }
  /// Member
  internal static let memberGroups = L10n.tr("Localizable", "member_groups")
  /// Owned
  internal static let ownedGroups = L10n.tr("Localizable", "owned_groups")
  /// Photo from %@
  internal static func photoFrom(_ p1: String) -> String {
    return L10n.tr("Localizable", "photo_from", p1)
  }
  /// Prompt Authorization
  internal static let promptAuthorization = L10n.tr("Localizable", "prompt_authorization")
  /// Purchased
  internal static let purchased = L10n.tr("Localizable", "purchased")
  /// Purchasing
  internal static let purchasing = L10n.tr("Localizable", "purchasing")
  /// Restored
  internal static let restored = L10n.tr("Localizable", "restored")
  /// Reset public and private keys
  internal static let subtilteResetKeys = L10n.tr("Localizable", "subtilte_reset_keys")
  /// Automatically save sent taps
  internal static let subtitleAutoAve = L10n.tr("Localizable", "subtitle_auto_ave")
  /// Play song from current position when video starts
  internal static let subtitleMusicPlayback = L10n.tr("Localizable", "subtitle_music_playback")
  /// iOS app settings
  internal static let subtitleSettings = L10n.tr("Localizable", "subtitle_settings")
  /// Visualize touches on screen
  internal static let subtitleVisualizer = L10n.tr("Localizable", "subtitle_visualizer")
  /// Auto-Save
  internal static let titleAutoSave = L10n.tr("Localizable", "title_auto_save")
  /// Camera
  internal static let titleCamera = L10n.tr("Localizable", "title_camera")
  /// Cancel
  internal static let titleCancel = L10n.tr("Localizable", "title_cancel")
  /// Cancel Send
  internal static let titleCancelSend = L10n.tr("Localizable", "title_cancel_send")
  /// Create
  internal static let titleCreate = L10n.tr("Localizable", "title_create")
  /// Delete
  internal static let titleDelete = L10n.tr("Localizable", "title_delete")
  /// Delete Group
  internal static let titleDeleteGroup = L10n.tr("Localizable", "title_delete_group")
  /// Done
  internal static let titleDone = L10n.tr("Localizable", "title_done")
  /// Group Name
  internal static let titleGroupName = L10n.tr("Localizable", "title_group_name")
  /// iCloud
  internal static let titleIcloud = L10n.tr("Localizable", "title_icloud")
  /// Image
  internal static let titleImage = L10n.tr("Localizable", "title_image")
  /// Join Tapsnap group
  internal static let titleJoinGroup = L10n.tr("Localizable", "title_join_group")
  /// Location
  internal static let titleLocation = L10n.tr("Localizable", "title_location")
  /// Logged Out
  internal static let titleLoggedOut = L10n.tr("Localizable", "title_logged_out")
  /// Login
  internal static let titleLogin = L10n.tr("Localizable", "title_login")
  /// Microphone
  internal static let titleMicrophone = L10n.tr("Localizable", "title_microphone")
  /// Music Sync
  internal static let titleMusicSync = L10n.tr("Localizable", "title_music_sync")
  /// My Groups
  internal static let titleMyGroups = L10n.tr("Localizable", "title_my_groups")
  /// New Group
  internal static let titleNewGroup = L10n.tr("Localizable", "title_new_group")
  /// No Connectivity
  internal static let titleNoConnectivity = L10n.tr("Localizable", "title_no_connectivity")
  /// You have no friends.
  internal static let titleNoFriends = L10n.tr("Localizable", "title_no_friends")
  /// Notifications
  internal static let titleNotifications = L10n.tr("Localizable", "title_notifications")
  /// Profile
  internal static let titleProfile = L10n.tr("Localizable", "title_profile")
  /// Rename
  internal static let titleRename = L10n.tr("Localizable", "title_rename")
  /// Rename Group
  internal static let titleRenameGroup = L10n.tr("Localizable", "title_rename_group")
  /// Reset
  internal static let titleReset = L10n.tr("Localizable", "title_reset")
  /// Reset Keys
  internal static let titleResetKeys = L10n.tr("Localizable", "title_reset_keys")
  /// Saved Taps
  internal static let titleSavedTaps = L10n.tr("Localizable", "title_saved_taps")
  /// Search
  internal static let titleSearch = L10n.tr("Localizable", "title_search")
  /// Settings
  internal static let titleSettings = L10n.tr("Localizable", "title_settings")
  /// Share
  internal static let titleShare = L10n.tr("Localizable", "title_share")
  /// Sort by Date
  internal static let titleSortByDate = L10n.tr("Localizable", "title_sort_by_date")
  /// Sort by Name
  internal static let titleSortByName = L10n.tr("Localizable", "title_sort_by_name")
  /// Visualizer
  internal static let titleVisualizer = L10n.tr("Localizable", "title_visualizer")
  /// Unknown
  internal static let unknown = L10n.tr("Localizable", "unknown")
  /// Video from %@
  internal static func videoFrom(_ p1: String) -> String {
    return L10n.tr("Localizable", "video_from", p1)
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    // swiftlint:disable:next nslocalizedstring_key
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
