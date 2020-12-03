//
//  P2PBeacon.PeerInfo.swift
//  BeaconSDK
//
//  Created by Julia Samol on 16.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    /// P2P peer data.
    public struct P2PPeerInfo: Equatable, Hashable, Codable {
        
        /// Type of connection which the data applies to.
        public let kind: Beacon.Connection.Kind
        
        /// The name of the peer.
        public let name: String
        
        /// The public key of the peer.
        public let publicKey: String
        
        /// The address of the server through which the peer should be communicated.
        public let relayServer: String
        
        /// The Beacon version using by the peer. If not provided, the earliest version will be assumed by default.
        public let version: String?
        
        /// An optional URL for the peer icon.
        public let icon: String?
        
        /// An optional URL for the peer application.
        public let appURL: URL?
        
        public init(
            name: String,
            publicKey: String,
            relayServer: String,
            version: String? = nil,
            icon: String? = nil,
            appURL: URL? = nil
        ) {
            kind = .p2p
            self.name = name
            self.publicKey = publicKey
            self.relayServer = relayServer
            self.version = version
            self.icon = icon
            self.appURL = appURL
        }
    }
}
