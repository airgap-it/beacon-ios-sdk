//
//  P2PBeacon.PeerInfo.swift
//  BeaconSDK
//
//  Created by Julia Samol on 16.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    public struct P2PPeerInfo: Equatable, Hashable, Codable {
        public let kind: Beacon.Connection.Kind
        public let name: String
        public let publicKey: String
        public let relayServer: String
        public let version: String?
        public let icon: String?
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
