// CloudKitKeys.swift
// Copyright (c) 2020 Tapsnap, LLC

import UIKit

enum UserKey: String {
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
    case photo
    case movie
    case creator
}

enum SigningKey: String {
    case key
    case creator
}
