// CloudKitKeys.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

enum UserAliasKey: String {
    case name
    case avatar
    case creator
}

enum GroupKey: String {
    case name
    case avatar
    case userCount
    case creator
}

enum MessageKey: String {
    case media
    case ciphertext
    case signature
    case senderSigningKey
    case recipient
    case notification
}

enum CryptoKey: String {
    case encryption
    case signing
    case creator
}
