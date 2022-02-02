//
//  Wallet.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import Base58Swift
import BeaconCore

extension Substrate {
    
    public class Wallet {
        private static let contextPrefix = "SS58PRE"
        
        private let crypto: Crypto
        
        init(crypto: Crypto) {
            self.crypto = crypto
        }
        
        public func address(fromPublicKey publicKey: String, withPrefix prefix: Int) throws -> String {
            let version = withUnsafeBytes(of: prefix.bigEndian, Array.init)
            let payload = try HexString(from: publicKey).asBytes()
            guard payload.count == 32 else {
                throw Beacon.Error.invalidPublicKey(publicKey, causedBy: nil)
            }
            
            let checksum = try checksum(from: payload)
            let checksumBytes = payload.count == 32 ? 2 : 1
            
            return Base58.base58Encode(version + payload + Array(checksum[0..<checksumBytes]))
        }
        
        private func checksum(from input: [UInt8]) throws -> [UInt8] {
            try crypto.hash(message: Array(Wallet.contextPrefix.utf8) + input, size: 512)
        }
    }
}
