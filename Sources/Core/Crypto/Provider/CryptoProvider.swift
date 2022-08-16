//
//  CryptoProvider.swift
//
//
//  Created by Julia Samol on 11.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

protocol CryptoProvider {
    func randomBytes(length: Int) throws -> [UInt8]
    
    func hash(message: [UInt8], size: Int) throws -> [UInt8]
    
    func ed25519KeyPair(from seed: [UInt8]) throws -> KeyPair
    func convertToCurve25519(ed25519SecretKey key: [UInt8]) throws -> [UInt8]
    func convertToCurve25519(ed25519PublicKey key: [UInt8]) throws -> [UInt8]
    func serverSessionKeyPair(serverPublicKey: [UInt8], serverSecretKey: [UInt8], clientPublicKey: [UInt8]) throws -> SessionKeyPair
    func clientSessionKeyPair(serverPublicKey: [UInt8], serverSecretKey: [UInt8], clientPublicKey: [UInt8]) throws -> SessionKeyPair
    
    func signDetached(message: [UInt8], with key: [UInt8]) throws -> [UInt8]
    
    func validate(encrypted: String) -> Bool
    func encrypt(message: [UInt8], withPublicKey key: [UInt8]) throws -> [UInt8]
    func decrypt(message: [UInt8], withPublicKey publicKey: [UInt8], andSecretKey: [UInt8]) throws -> [UInt8]
    func encrypt(message: [UInt8], withSharedKey key: [UInt8]) throws -> [UInt8]
    func decrypt(message: [UInt8], withSharedKey key: [UInt8]) throws -> [UInt8]
}
