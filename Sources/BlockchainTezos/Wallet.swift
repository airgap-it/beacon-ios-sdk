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
    
    public class Wallet {
        private let crypto: Crypto
        
        init(crypto: Crypto) {
            self.crypto = crypto
        }
        
        public func address(fromPublicKey publicKey: String) throws -> String {
            let payload = try crypto.hash(message: try publicKey.toBytes(), size: 20)
            return Base58.base58CheckEncode(Tezos.PrefixBytes.tz1 + payload)
        }
    }
}

// MARK: Extensions

private extension String {
    var isPlainPublicKey: Bool {
        (count == 64 || count == 66) && isHex
    }
    
    var isEncryptedPublicKey: Bool {
        count == 54 && hasPrefix(Tezos.Prefix.edpk)
    }
    
    func toBytes() throws -> [UInt8] {
        if isPlainPublicKey {
            return try HexString(from: self).asBytes()
        } else if isEncryptedPublicKey {
            guard let decoded = Base58.base58CheckDecode(self) else {
                throw Beacon.Error.invalidPublicKey(self)
            }
            
            return Array(decoded[Tezos.Prefix.edpk.count...])
        } else {
            throw Beacon.Error.invalidPublicKey(self)
        }
    }
}
