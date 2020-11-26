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
        let nodes: [URL]
        
        init(crypto: Crypto, nodes: [URL]) {
            self.crypto = crypto
            self.nodes = nodes
        }
        
        // MARK: Relay Server
        
        func relayServer(for publicKey: HexString, nonce: HexString? = nil) throws -> URL {
            try relayServer(for: try publicKey.bytes(), nonce: nonce)
        }
        
        func relayServer(for publicKey: [UInt8], nonce: HexString? = nil) throws -> URL {
            let hash = try crypto.hash(key: publicKey)
            let nonceValue = nonce?.value() ?? ""
            
            let relayServer = try nodes.min { (first, second) in
                let firstDistance = try distance(from: hash, to: first.absoluteString + nonceValue)
                let secondDistance = try distance(from: hash, to: second.absoluteString + nonceValue)
                
                return firstDistance <= secondDistance
            }
            
            if let relayServer = relayServer {
                return relayServer
            } else {
                throw Error.emptyNodes
            }
        }
        
        private func distance(from hash: [UInt8], to message: String) throws -> Decimal {
            hash.distance(to: try crypto.hash(message: message, size: 32))
        }
        
        // MARK: Types
        
        enum Error: Swift.Error {
            case emptyNodes
        }
    }
}

// MARK: Extensions

extension Array where Element == UInt8 {
    
    func distance(to other: [UInt8]) -> Decimal {
        Decimal(self).distance(to: Decimal(other))
    }
}

extension Decimal {
    
    init(_ bytes: [UInt8]) {
        self = bytes.map { Decimal($0) }.reduce(Decimal()) { $0 * 256 + $1 }
    }
}
