//
//  PairingResponse.swift
//  
//
//  Created by Julia Samol on 10.08.22.
//

import Foundation

public enum BeaconPairingResponse: Codable, Hashable, BeaconPairingResponseProtocol {
    static let typeSuffix = "response"
    
    case p2p(Transport.P2P.PairingResponse)
    
    // MARK: Attributes
    
    public var id: String {
        common.id
    }
    
    public var name: String {
        common.name
    }
    
    public var version: String {
        common.version
    }
    
    public var publicKey: String {
        common.publicKey
    }
    
    private var common: BeaconPairingResponseProtocol {
        switch self {
        case let .p2p(content):
            return content
        }
    }
    
    public func toPeer() -> Beacon.Peer {
        common.toPeer()
    }
    
    // MARK: Codable
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(String.self, forKey: .type)
        if type == Transport.P2P.PairingMessage.Kind.response.rawValue {
            self = .p2p(try .init(from: decoder))
        } else {
            throw Beacon.Error.unknownMessageType(type, version: Beacon.Configuration.beaconVersion)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .p2p(content):
            try content.encode(to: encoder)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type
    }
}

// MARK: Protocol

public protocol BeaconPairingResponseProtocol: BeaconPairingMessageProtocol {}
