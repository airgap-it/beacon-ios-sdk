//
//  Beacon.P2PPeer.swift
//
//
//  Created by Julia Samol on 16.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    /// P2P peer data.
    public struct P2PPeer: PeerProtocol, Equatable, Hashable, Codable {
        
        /// Type of connection which the data applies to.
        public let kind: Beacon.Connection.Kind
        
        /// A unique identifier for the peer.
        public let id: String?
        
        /// The name of the peer.
        public let name: String
        
        /// The public key of the peer.
        public let publicKey: String
        
        /// The address of the server through which the peer should be communicated.
        public let relayServer: String
        
        /// The Beacon version using by the peer. If not provided, the earliest version will be assumed by default.
        public let version: String
        
        /// An optional URL for the peer icon.
        public let icon: String?
        
        /// An optional URL for the peer application.
        public let appURL: URL?
        
        public let isPaired: Bool
        
        public init(
            id: String? = nil,
            name: String,
            publicKey: String,
            relayServer: String,
            version: String,
            icon: String? = nil,
            appURL: URL? = nil
        ) {
            self.init(
                id: id,
                name: name,
                publicKey: publicKey,
                relayServer: relayServer,
                version: version,
                icon: icon,
                appURL: appURL,
                isPaired: false
            )
        }
        
        init(
            id: String? = nil,
            name: String,
            publicKey: String,
            relayServer: String,
            version: String,
            icon: String? = nil,
            appURL: URL? = nil,
            isPaired: Bool = false
        ) {
            kind = .p2p
            self.id = id
            self.name = name
            self.publicKey = publicKey
            self.relayServer = relayServer
            self.version = version
            self.icon = icon
            self.appURL = appURL
            self.isPaired = isPaired
        }
        
        public func toConnectionID() -> Beacon.Connection.ID {
            .p2p(id: publicKey)
        }
        
        // MARK: Codable
        
        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            kind = .p2p
            id = try values.decodeIfPresent(String.self, forKey: .id)
            name = try values.decode(String.self, forKey: .name)
            publicKey = try values.decode(String.self, forKey: .publicKey)
            relayServer = try values.decode(String.self, forKey: .relayServer)
            version = try values.decodeIfPresent(String.self, forKey: .version) ?? "1"
            icon = try values.decodeIfPresent(String.self, forKey: .icon)
            appURL = try values.decodeIfPresent(URL.self, forKey: .appURL)
            isPaired = try values.decodeIfPresent(Bool.self, forKey: .isPaired) ?? /* backwards compatibilty */ true
        }
        
        enum CodingKeys: String, CodingKey {
            case kind
            case id
            case name
            case publicKey
            case relayServer
            case version
            case icon
            case appURL
            case isPaired
        }
        
        // MARK: Internal
        
        public init(
            from peer: P2PPeer,
            id: String?? = nil,
            name: String? = nil,
            publicKey: String? = nil,
            relayServer: String? = nil,
            version: String? = nil,
            icon: String?? = nil,
            appURL: URL?? = nil,
            isPaired: Bool? = nil
        ) {
            self.init(
                id: id ?? peer.id,
                name: name ?? peer.name,
                publicKey: publicKey ?? peer.publicKey,
                relayServer: relayServer ?? peer.relayServer,
                version: version ?? peer.version,
                icon: icon ?? peer.icon,
                appURL: appURL ?? peer.appURL,
                isPaired: isPaired ?? peer.isPaired
            )
        }
    }
}
