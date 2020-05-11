// Aliases.swift
// Copyright (c) 2020 Tapsnap, LLC

import Foundation

typealias SealedMessage = (ephemeralPublicKeyData: Data, ciphertextData: Data, signatureData: Data)
typealias SealedURL = (ephemeralPublicKeyURL: URL, ciphertexURL: URL, signatureURL: URL)
