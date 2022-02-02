//
//  Network.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

extension Substrate {
    
    /// Substrate network data.
    public struct Network: NetworkProtocol, Codable, Equatable {
        /// The genesis hash of the chain.
        public let genesisHash: String
        
        /// An optional name of the network.
        public let name: String?
        
        /// An optional URL for the network RPC interface.
        public let rpcURL: String?
        
        /// The unique value that identifies the network.
        public var identifier: String {
            var data = [genesisHash]
            
            if let name = name {
                data.append("name:\(name)")
            }
            
            if let rpcURL = rpcURL {
                data.append("rpc:\(rpcURL)")
            }
            
            return data.joined(separator: "-")
        }
        
        public init(genesisHash: String, name: String? = nil, rpcURL: String? = nil) {
            self.genesisHash = genesisHash
            self.name = name
            self.rpcURL = rpcURL
        }
    }
}
