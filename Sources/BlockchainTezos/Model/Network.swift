//
//  Network.swift
//  
//
//  Created by Julia Samol on 30.09.21.
//

import Foundation
import BeaconCore

extension Tezos {
    
    /// A group of values defining a network in Tezos..
    public struct Network: NetworkProtocol, Codable, Hashable {
        public static let mainnet: Network = .init(type: .mainnet)
        
        public static let ghostnet: Network = .init(type: .ghostnet)
        public static let mondaynet: Network = .init(type: .mondaynet)
        public static let dailynet: Network = .init(type: .dailynet)
        
        @available(*, deprecated, message: "'Ithacanet' is no longer a maintained Tezos test network and will be removed from Beacon in future versions.")
        public static let ithacanet: Network = .init(type: .ithacanet)
        
        @available(*, deprecated, message: "'Jakartanet' is no longer a maintained Tezos test network and will be removed from Beacon in future versions.")
        public static let jakartanet: Network = .init(type: .jakartanet)
        
        public static let kathmandunet: Network = .init(type: .kathmandunet)
        public static let limanet: Network = .init(type: .limanet)
        public static let mumbainet: Network = .init(type: .mumbainet)
        
        /// A type of the network
        public let type: `Type`
        
        /// An optional name of the network.
        public let name: String?
        
        /// An optional URL for the network RPC interface.
        public let rpcURL: String?
        
        /// The unique value that identifies the network.
        public var identifier: String {
            var data = [type.rawValue]
            
            if let name = name {
                data.append("name:\(name)")
            }
            
            if let rpcURL = rpcURL {
                data.append("rpc:\(rpcURL)")
            }
            
            return data.joined(separator: "-")
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
            
            case ghostnet
            case mondaynet
            case dailynet
            
            @available(*, deprecated, message: "'Delphinet' is no longer a maintained Tezos test network and will be removed from Beacon in future versions.")
            case delphinet
            
            @available(*, deprecated, message: "'Edonet' is no longer a maintained Tezos test network and will be removed from Beacon in future versions.")
            case edonet
            
            @available(*, deprecated, message: "'Florencenet' is no longer a maintained Tezos test network and will be removed from Beacon in future versions.")
            case florencenet
            
            @available(*, deprecated, message: "'Granadanet' is no longer a maintained Tezos test network and will be removed from Beacon in future versions.")
            case granadanet
            
            @available(*, deprecated, message: "'Hangzhounet' is no longer a maintained Tezos test network and will be removed from Beacon in future versions.")
            case hangzhounet
            
            @available(*, deprecated, message: "'Ithacanet' is no longer a maintained Tezos test network and will be removed from Beacon in future versions.")
            case ithacanet
            
            @available(*, deprecated, message: "'Jakartanet' is no longer a maintained Tezos test network and will be removed from Beacon in future versions.")
            case jakartanet
            
            case kathmandunet
            case limanet
            case mumbainet
            
            case custom
        }
    }
}
