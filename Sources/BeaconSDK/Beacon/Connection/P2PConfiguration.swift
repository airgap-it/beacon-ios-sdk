//
//  P2PConfiguration.swift
//  BeaconSDK
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Connection {
    
    /// A group of values required to setup a P2P connection.
    public struct P2PConfiguration: Equatable, Hashable {
        let kind: Kind
        
        /// URLs of the servers used in the P2P connection.
        public let nodes: [String]
        
        ///
        /// Creates a default P2P configuration.
        ///
        /// By default `Beacon.Configuration.defaultRealayServers` are used as the `nodes`.
        ///
        public init() {
            kind = .p2p
            self.nodes = Beacon.Configuration.defaultRelayServers
        }
        
        
        ///
        /// Creates a P2P configuration with custom server URLs.
        ///
        /// - Parameter nodes: The URLs to be used in the P2P connection.
        ///
        public init(nodes: [String]) throws {
            guard !nodes.isEmpty else {
                throw Beacon.Error.emptyNodes
            }
            
            kind = .p2p
            self.nodes = nodes
        }
    }
}
