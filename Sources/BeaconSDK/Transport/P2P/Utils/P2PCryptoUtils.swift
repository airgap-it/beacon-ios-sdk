//
//  P2PCryptoUtils.swift
//  
//
//  Created by Julia Samol on 31.08.21.
//

import Foundation

extension Transport.P2P {
    
    class CryptoUtils {
        private let app: Beacon.Application
        private let crypto: Crypto
        private let timeUtils: TimeUtilsProtocol
        
        private var keyPair: KeyPair { app.keyPair }
        
        private var serverSessionKeyPair: [HexString: SessionKeyPair] = [:]
        private var clientSessionKeyPair: [HexString: SessionKeyPair] = [:]
        
        init(app: Beacon.Application, crypto: Crypto, timeUtils: TimeUtilsProtocol) {
            self.app = app
            self.crypto = crypto
            self.timeUtils = timeUtils
        }
        
        func userID() throws -> String {
            HexString(from: try crypto.hash(key: keyPair.publicKey)).asString()
        }
        
        func password() throws -> String {
            let loginDigest = try crypto.hash(message: "login:\(timeUtils.currentTimeMillis / 1000 / (5 * 60))", size: 32)
            let signature = HexString(from: try crypto.signDetached(message: loginDigest, with: keyPair.secretKey)).asString()
            let publicKeyHex = HexString(from: keyPair.publicKey).asString()
            
            return "ed:\(signature):\(publicKeyHex)"
        }
        
        func deviceID() throws -> String {
            HexString(from: keyPair.publicKey).asString()
        }
        
        func encryptPairingPayload(_ pairingPayload: String, with publicKey: [UInt8]) throws -> [UInt8] {
            try crypto.encrypt(message: pairingPayload, withPublicKey: publicKey)
        }
        
        func encrypt(message: String, with publicKey: [UInt8]) throws -> [UInt8] {
            let keyPair = try getOrCreateClientSessionKeyPair(for: publicKey)
            
            return try crypto.encrypt(message: message, withSharedKey: keyPair.tx)
        }
        
        func decrypt(message encrypted: Matrix.Event.TextMessage, with publicKey: [UInt8]) throws -> String {
            let keyPair = try getOrCreateServerSessionKeyPair(for: publicKey)
            
            let decrypted: [UInt8] = try {
                if encrypted.message.isHex {
                    return try crypto.decrypt(message: try HexString(from: encrypted.message), withSharedKey: keyPair.rx)
                } else {
                    return try crypto.decrypt(message: encrypted.message, withSharedKey: keyPair.rx)
                }
            }()
                
            return String(bytes: decrypted, encoding: .utf8) ?? ""
        }
        
        private func getOrCreateClientSessionKeyPair(for publicKey: [UInt8]) throws -> SessionKeyPair {
            try clientSessionKeyPair.get(HexString(from: publicKey)) {
                try crypto.clientSessionKeyPair(publicKey: publicKey, secretKey: keyPair.secretKey)
            }
        }
        
        private func getOrCreateServerSessionKeyPair(for publicKey: [UInt8]) throws -> SessionKeyPair {
            try serverSessionKeyPair.get(HexString(from: publicKey)) {
                try crypto.serverSessionKeyPair(publicKey: publicKey, secretKey: keyPair.secretKey)
            }
        }
    }
}

// MARK: Extensions

private extension Dictionary where Key == HexString {
    
    mutating func getOrSet(_ key: [UInt8], setter: () throws -> Value) rethrows -> Value {
        try get(HexString(from: key), orSet: setter)
    }
}
