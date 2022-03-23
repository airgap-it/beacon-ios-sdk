//
//  Wallet.swift
//  
//
//  Created by Julia Samol on 28.09.21.
//

import Foundation
import Base58Swift
import BeaconCore

extension Tezos {
    
    class Wallet {
        private let crypto: Crypto
        
        init(crypto: Crypto) {
            self.crypto = crypto
        }
        
        public func address(fromPublicKey publicKey: String) throws -> String {
            let publicKey = try PublicKey(from: publicKey)
            let payload = try crypto.hash(message: publicKey.bytes, size: 20)
            
            return Base58.base58CheckEncode(publicKey.prefix.toAddress() + payload)
        }
    }
    
    fileprivate struct PublicKey {
        let prefix: Tezos.Prefix.PublicKey
        let bytes: [UInt8]
    }
}

// MARK: Extensions

private extension Tezos.PublicKey {
    
    init(from string: String) throws {
        if string.isPlainPublicKey {
            self.init(prefix: .ed25519, bytes: try HexString(from: string).asBytes())
        } else if string.isEncryptedPublicKey {
            guard let prefix = string.publicKeyPrefix() else {
                throw Beacon.Error.invalidPublicKey(string)
            }
            
            guard let decoded = Base58.base58CheckDecode(string) else {
                throw Beacon.Error.invalidPublicKey(string)
            }
            
            self.init(prefix: prefix, bytes: Array(decoded[prefix.bytes.count...]))
        } else {
            throw Beacon.Error.invalidPublicKey(string)
        }
    }
}

private extension Tezos.Prefix.PublicKey {
    func toAddress() -> Tezos.Prefix.Address {
        switch self {
        case .ed25519:
            return .ed25519
        case .secp256K1:
            return .secp256K1
        case .p256:
            return .p256
        }
    }
}

private extension TezosPrefixProtocol {
    static func +(left: Self, right: [UInt8]) -> [UInt8] {
        left.bytes + right
    }
}

private extension String {
    var isPlainPublicKey: Bool {
        (count == 64 || count == 66) && isHex
    }

    var isEncryptedPublicKey: Bool {
        guard let prefix = publicKeyPrefix() else {
            return false
        }
        
        return count == prefix.encodedCount
    }
    
    func publicKeyPrefix() -> Tezos.Prefix.PublicKey? {
        Tezos.Prefix.PublicKey.allCases.first(where: { hasPrefix($0) })
    }
    
    func hasPrefix(_ prefix: TezosPrefixProtocol) -> Bool {
        hasPrefix(prefix.value)
    }
}
