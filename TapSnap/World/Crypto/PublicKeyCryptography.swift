//
//  EncryptDecrypt.swift
//  Tapsnap
//
//  Created by Joe Blau on 3/1/20.
//

import Foundation
import CryptoKit

struct PublicKeyCryptography {
    let protocolSalt = "Working on the weekend as usual, way off in the deepend as usual".data(using: .utf8)!
    
    /// Generates an ephemeral key agreement key and performs key agreement to get the shared secret and derive the symmetric encryption key.
    func encrypt(_ data: Data, to theirEncryptionKey: Curve25519.KeyAgreement.PublicKey, signedBy ourSigningKey: Curve25519.Signing.PrivateKey) throws ->
        (ephemeralPublicKeyData: Data, ciphertext: Data, signature: Data) {
            let ephemeralKey = Curve25519.KeyAgreement.PrivateKey()
            let ephemeralPublicKey = ephemeralKey.publicKey.rawRepresentation
            
            let sharedSecret = try ephemeralKey.sharedSecretFromKeyAgreement(with: theirEncryptionKey)
            
            let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(using: SHA256.self,
                                                                    salt: protocolSalt,
                                                                    sharedInfo: ephemeralPublicKey +
                                                                        theirEncryptionKey.rawRepresentation +
                                                                        ourSigningKey.publicKey.rawRepresentation,
                                                                    outputByteCount: 32)
            
            let ciphertext = try ChaChaPoly.seal(data, using: symmetricKey).combined
            let signature = try ourSigningKey.signature(for: ciphertext + ephemeralPublicKey + theirEncryptionKey.rawRepresentation)
            
            return (ephemeralPublicKey, ciphertext, signature)
    }
    
    enum DecryptionErrors: Error {
        case authenticationError
    }
    
    /// Generates an ephemeral key agreement key and the performs key agreement to get the shared secret and derive the symmetric encryption key.
    func decrypt(_ sealedMessage: (ephemeralPublicKeyData: Data, ciphertext: Data, signature: Data),
                 using ourKeyEncryptionKey: Curve25519.KeyAgreement.PrivateKey,
                 from theirSigningKey: Curve25519.Signing.PublicKey) throws -> Data {
        let data = sealedMessage.ciphertext + sealedMessage.ephemeralPublicKeyData + ourKeyEncryptionKey.publicKey.rawRepresentation
        guard theirSigningKey.isValidSignature(sealedMessage.signature, for: data) else {
            throw DecryptionErrors.authenticationError
        }
        
        let ephemeralKey = try Curve25519.KeyAgreement.PublicKey(rawRepresentation: sealedMessage.ephemeralPublicKeyData)
        let sharedSecret = try ourKeyEncryptionKey.sharedSecretFromKeyAgreement(with: ephemeralKey)
        
        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(using: SHA256.self,
                                                                salt: protocolSalt,
                                                                sharedInfo: ephemeralKey.rawRepresentation +
                                                                    ourKeyEncryptionKey.publicKey.rawRepresentation +
                                                                    theirSigningKey.rawRepresentation,
                                                                outputByteCount: 32)
        
        let sealedBox = try! ChaChaPoly.SealedBox(combined: sealedMessage.ciphertext)
        
        return try ChaChaPoly.open(sealedBox, using: symmetricKey)
    }
}
