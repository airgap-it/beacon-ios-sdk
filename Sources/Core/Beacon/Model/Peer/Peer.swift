//
//  Peer.swift
//
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    /// Types of peers supported in Beacon.
    public enum Peer: PeerProtocol, Equatable, Hashable, Codable {
        
        ///
        /// Peer details required in the P2P connection.
        ///
        /// - peer: The peer data.
        case p2p(_ peer: P2PPeer)
        
        // MARK: Attributes
        
        public var kind: Beacon.Connection.Kind { common.kind }
        public var id: String? { common.id }
        public var name: String { common.name }
        public var publicKey: String { common.publicKey }
        public var version: String { common.version }
        
        private var common: PeerProtocol {
            switch self {
            case let .p2p(content):
                return content
            }
        }
        
        // MARK: Codable
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let kind = try container.decode(Beacon.Connection.Kind.self, forKey: .kind)
            switch kind {
            case .p2p:
                self = .p2p(try P2PPeer(from: decoder))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            switch self {
            case let .p2p(content):
                try content.encode(to: encoder)
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case kind
        }
    }
}

// MARK: Protocol

public protocol PeerProtocol {
    var kind: Beacon.Connection.Kind { get }
    var id: String? { get }
    var name: String { get }
    var publicKey: String { get }
    var version: String { get }
}
