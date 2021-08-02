//
//  Network.swift
//  BeaconSDK
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    /// A group of values defining a network in Beacon.
    public struct Network: Codable, Equatable {
        
        /// A type of the network
        public let type: `Type`
        
        /// An optional name of the network.
        public let name: String?
        
        /// An optional URL for the network RPC interface.
        public let rpcURL: String?
        
        /// A unique value that identifies the network.
        var identifier: String {
            type.rawValue
        }
        
        public init(type: `Type`, name: String? = nil, rpcURL: String? = nil) {
            self.type = type
            self.name = name
            self.rpcURL = rpcURL
        }
        
        enum CodingKeys: String, CodingKey {
            case type
            case name
            case rpcURL = "rpcUrl"
        }
        
        /// Types of supported networks.
        public enum `Type`: String, Codable {
            case mainnet
            case carthagenet
            case delphinet
            case edonet
            case florencenet
            case granadanet
            case custom
        }
    }
}
