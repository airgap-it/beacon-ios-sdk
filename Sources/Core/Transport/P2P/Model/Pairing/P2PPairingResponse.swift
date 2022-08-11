//
//  P2PPairingResponse.swift
//
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public extension Transport.P2P {
    
    struct PairingResponse: Identifiable, Hashable, Codable, BeaconPairingResponseProtocol, TransportP2PPairingMessageProtocol {
        public let id: String
        public let type: PairingMessage.Kind
        public let name: String
        public let version: String
        public let publicKey: String
        public let relayServer: String
        public let icon: String?
        public let appURL: String?
        
        public init(id: String, name: String, version: String, publicKey: String, relayServer: String, icon: String?, appURL: String?) {
            self.type = .response
            self.id = id
            self.name = name
            self.version = version
            self.publicKey = publicKey
            self.relayServer = relayServer
            self.icon = icon
            self.appURL = appURL
        }
        
        public func toPeer() -> Beacon.Peer {
            .p2p(.init(id: id, name: name, publicKey: publicKey, relayServer: relayServer, version: version, icon: icon, appURL: URL(string: appURL)))
        }
        
        // MARK: Codable
        
        enum CodingKeys: String, CodingKey {
            case id
            case type
            case name
            case version
            case publicKey
            case relayServer
            case icon
            case appURL = "appUrl"
        }
    }
}
