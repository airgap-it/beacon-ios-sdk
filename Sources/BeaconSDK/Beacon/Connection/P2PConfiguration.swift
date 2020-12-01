//
//  P2PConfiguration.swift
//  BeaconSDK
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Connection {
    
    public struct P2PConfiguration: Equatable, Hashable {
        let kind: Kind
        public let nodes: [URL]
        
        public init() {
            kind = .p2p
            self.nodes = Beacon.Configuration.defaultRelayServers
        }
        
        public init(nodes: [URL]) throws {
            guard !nodes.isEmpty else {
                throw Beacon.Error.emptyNodes
            }
            
            kind = .p2p
            self.nodes = nodes
        }
    }
}
