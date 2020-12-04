//
//  Connection.swift
//  BeaconSDK
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    /// Connection types supported in Beacon.
    public enum Connection: Equatable, Hashable {
        
        ///
        /// P2P (Peer-to-peer) connection.
        ///
        /// - configuration: A group of values required to configure the connection.
        /// By default `Beacon.Configure.defaultRelayServers` is used as the nodes.
        ///
        case p2p(_ configuration: P2PConfiguration = P2PConfiguration())
        
        /// Raw type of the connection.
        public var kind: Kind {
            switch self {
            case let .p2p(content):
                return content.kind
            }
        }
        
        /// Raw values of types
        public enum Kind: String, Codable {
            case p2p
        }
    }
}
