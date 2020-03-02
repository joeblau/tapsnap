//
//  Aliases.swift
//  Tapsnap
//
//  Created by Joe Blau on 3/1/20.
//

import Foundation

typealias SealedMessage = (ephemeralPublicKeyData: Data, ciphertextData: Data, signatureData: Data)
typealias SealedURL = (ephemeralPublicKeyURL: URL, ciphertexURL: URL, signatureURL: URL)
