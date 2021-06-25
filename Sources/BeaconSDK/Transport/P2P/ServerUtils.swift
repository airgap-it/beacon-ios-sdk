//
//  ServerUtils.swift
//  BeaconSDK
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Transport.P2P {
    
    class ServerUtils {
        let crypto: Crypto
        let nodes: [String]
        
        init(crypto: Crypto, nodes: [String]) {
            self.crypto = crypto
            self.nodes = nodes
        }
        
        // MARK: Relay Server
        
        func relayServer(for publicKey: HexString, nonce: HexString? = nil) throws -> String {
            try relayServer(for: try publicKey.asBytes(), nonce: nonce)
        }
        
        func relayServer(for publicKey: [UInt8], nonce: HexString? = nil) throws -> String {
            let hash = try crypto.hash(key: publicKey)
            let nonceValue = nonce?.asString() ?? ""
            
            let relayServer = try nodes.min { (first, second) in
                let firstDistance = try distance(from: hash, to: first + nonceValue)
                let secondDistance = try distance(from: hash, to: second + nonceValue)
                
                return firstDistance <= secondDistance
            }
            
            if let relayServer = relayServer {
                return relayServer
            } else {
                throw Beacon.Error.emptyNodes
            }
        }
        
        private func distance(from hash: [UInt8], to message: String) throws -> Decimal {
            hash.distance(to: try crypto.hash(message: message, size: 32))
        }
    }
}

// MARK: Extensions

private extension Array where Element == UInt8 {
    
    func distance(to other: [UInt8]) -> Decimal {
        Decimal(self).distance(to: Decimal(other))
    }
}

private extension Decimal {
    
    init(_ bytes: [UInt8]) {
        self = bytes.map { Decimal($0) }.reduce(Decimal()) { $0 * 256 + $1 }
    }
}
