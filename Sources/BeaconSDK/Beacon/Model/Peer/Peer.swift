//
//  Peer.swift
//  BeaconSDK
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    /// Types of peers supported in Beacon.
    public enum Peer: Equatable, Hashable, Codable {
        
        ///
        /// Peer details required in the P2P connection.
        ///
        /// - peers: The peer data.
        case p2p(_ peers: P2PPeer)
        
        // MARK: Attributes
        
        var common: PeerProtocol {
            switch self {
            case let .p2p(content):
                return content
            }
        }
        
        func matches(appMetadata: AppMetadata, using accountUtils: AccountUtilsProtocol) -> Bool {
            do {
                return try accountUtils.getSenderID(from: try HexString(from: common.publicKey)) == appMetadata.senderID
            } catch {
                return false
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

protocol PeerProtocol {
    var kind: Beacon.Connection.Kind { get }
    var id: String? { get }
    var name: String { get }
    var publicKey: String { get }
    var version: String { get }
}
