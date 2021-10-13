//
//  Crypto.swift
//
//
//  Created by Julia Samol on 11.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public class Crypto {
    private static let seedBytes = 16
    
    private let cryptoProvider: CryptoProvider
    
    init(provider cryptoProvider: CryptoProvider) {
        self.cryptoProvider = cryptoProvider
    }
    
    // MARK: Hash
    
    public func hash(message: String, size: Int) throws -> [UInt8] {
        try cryptoProvider.hash(message: message, size: size)
    }
    
    public func hash(message: HexString, size: Int) throws -> [UInt8] {
        try hash(message: try message.asBytes(), size: size)
    }
    
    public func hash(message: [UInt8], size: Int) throws -> [UInt8] {
        try cryptoProvider.hash(message: message, size: size)
    }
    
    public func hash(key: HexString) throws -> [UInt8] {
        try hash(key: try key.asBytes())
    }
    
    public func hash(key: [UInt8]) throws -> [UInt8] {
        try cryptoProvider.hash(message: key, size: key.count)
    }
    
    // MARK: Random
    
    public func guid() throws -> String {
        let bytes = try cryptoProvider.randomBytes(length: Crypto.seedBytes)
        
        return [bytes[0..<4], bytes[4..<6], bytes[6..<8], bytes[8..<10], bytes[10...]]
            .map { slice in HexString(from: Array(slice)).asString() }
            .joined(separator: "-")
    }
    
    // MARK: Keys
    
    public func keyPairFrom(seed: String) throws -> KeyPair {
        let hash = try cryptoProvider.hash(message: seed, size: 32)
        
        return try cryptoProvider.ed25519KeyPair(from: hash)
    }
    
    public func serverSessionKeyPair(publicKey: [UInt8], secretKey: [UInt8]) throws -> SessionKeyPair {
        let serverPublicKey = try cryptoProvider.convertToCurve25519(ed25519PublicKey: secretKey[32..<64])
        let serverSecretKey = try cryptoProvider.convertToCurve25519(ed25519SecretKey: secretKey)
        let clientPublicKey = try cryptoProvider.convertToCurve25519(ed25519PublicKey: publicKey)
            
        return try cryptoProvider.serverSessionKeyPair(
            serverPublicKey: serverPublicKey,
            serverSecretKey: serverSecretKey,
            clientPublicKey: clientPublicKey
        )
    }
    
    public func clientSessionKeyPair(publicKey: [UInt8], secretKey: [UInt8]) throws -> SessionKeyPair {
        let serverPublicKey = try cryptoProvider.convertToCurve25519(ed25519PublicKey: secretKey[32..<64])
        let serverSecretKey = try cryptoProvider.convertToCurve25519(ed25519SecretKey: secretKey)
        let clientPublicKey = try cryptoProvider.convertToCurve25519(ed25519PublicKey: publicKey)
        
        return try cryptoProvider.clientSessionKeyPair(
            serverPublicKey: serverPublicKey,
            serverSecretKey: serverSecretKey,
            clientPublicKey: clientPublicKey
        )
    }
    
    // MARK: Signature
    
    public func signDetached(message: [UInt8], with key: [UInt8]) throws -> [UInt8] {
        try cryptoProvider.signDetached(message: message, with: key)
    }
    
    // MARK: Encryption
    
    public func validate(encrypted: String) -> Bool {
        cryptoProvider.validate(encrypted: encrypted)
    }
    
    public func encrypt(message: String, withPublicKey key: [UInt8]) throws -> [UInt8] {
        try encrypt(message: [UInt8](message.utf8), withPublicKey: key)
    }
    
    public func encrypt(message: HexString, withPublicKey key: [UInt8]) throws -> [UInt8] {
        try encrypt(message: try message.asBytes(), withPublicKey: key)
    }
    
    public func encrypt(message: [UInt8], withPublicKey key: [UInt8]) throws -> [UInt8] {
        let curve25519Key = try cryptoProvider.convertToCurve25519(ed25519PublicKey: key)
        
        return try cryptoProvider.encrypt(message: message, withPublicKey: curve25519Key)
    }

    public func encrypt(message: String, withSharedKey key: [UInt8]) throws -> [UInt8] {
        try encrypt(message: [UInt8](message.utf8), withSharedKey: key)
    }
    
    public func encrypt(message: HexString, withSharedKey key: [UInt8]) throws -> [UInt8] {
        try encrypt(message: try message.asBytes(), withPublicKey: key)
    }
    
    public func encrypt(message: [UInt8], withSharedKey key: [UInt8]) throws -> [UInt8] {
        try cryptoProvider.encrypt(message: message, withSharedKey: key)
    }
    
    public func decrypt(message: String, withSharedKey key: [UInt8]) throws -> [UInt8] {
        try decrypt(message: [UInt8](message.utf8), withSharedKey: key)
    }
    
    public func decrypt(message: HexString, withSharedKey key: [UInt8]) throws -> [UInt8] {
        try decrypt(message: try message.asBytes(), withSharedKey: key)
    }
    
    public func decrypt(message: [UInt8], withSharedKey key: [UInt8]) throws -> [UInt8] {
        try cryptoProvider.decrypt(message: message, withSharedKey: key)
    }
}

// MARK: Extensions

private extension CryptoProvider {
    func hash(message: String, size: Int) throws -> [UInt8] {
        try hash(message: [UInt8](message.utf8), size: size)
    }
    
    func convertToCurve25519(ed25519PublicKey slice: ArraySlice<UInt8>) throws -> [UInt8] {
        try convertToCurve25519(ed25519PublicKey: Array(slice))
    }
}
