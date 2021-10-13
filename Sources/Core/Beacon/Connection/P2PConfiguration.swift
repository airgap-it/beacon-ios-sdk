//
//  P2PConfiguration.swift
//
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Connection {
    
    /// A group of values required to setup a P2P connection.
    public struct P2PConfiguration {
        let kind: Kind = .p2p
        
        /// A factory for a P2PClient instance that should be used in the P2P connection.
        public let client: P2PClientFactory
        
        public init(client: P2PClientFactory) {
            self.client = client
        }
    }
}
