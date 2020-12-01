//
//  Tezos.swift
//  BeaconSDK
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import Base58Swift

public class Tezos: Coin {
    private static let tz1Prefix: [UInt8] = [6, 161, 159]
    
    private let crypto: Crypto
    
    init(crypto: Crypto) {
        self.crypto = crypto
    }
    
    func getAddressFrom(publicKey: String) throws -> String {
        let payload = try crypto.hash(message: try publicKey.toBytes(), size: 20)
        return Base58.base58CheckEncode(Tezos.tz1Prefix + payload)
    }
}

// MARK: Extensions

private extension String {
    static let encryptedPublicKeyPrefix = "edpk"
    
    var isPlainPublicKey: Bool {
        (count == 64 || count == 66) && isHex
    }
    
    var isEncryptedPublicKey: Bool {
        count == 54 && hasPrefix(.encryptedPublicKeyPrefix)
    }
    
    func toBytes() throws -> [UInt8] {
        if isPlainPublicKey {
            return try HexString(from: self).asBytes()
        } else if isEncryptedPublicKey {
            guard let decoded = Base58.base58CheckDecode(self) else {
                throw Beacon.Error.invalidPublicKey(self)
            }
            
            return Array(decoded[String.encryptedPublicKeyPrefix.count...])
        } else {
            throw Beacon.Error.invalidPublicKey(self)
        }
    }
}
