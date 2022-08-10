//
//  PairingRequest.swift
//  
//
//  Created by Julia Samol on 10.08.22.
//

import Foundation

public enum BeaconPairingRequest: Codable, Hashable, BeaconPairingRequestProtocol {
    static let typeSuffix = "request"
    
    case p2p(Transport.P2P.PairingRequest)
    
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
    
    private var common: BeaconPairingRequestProtocol {
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
        if type == Transport.P2P.PairingMessage.Kind.request.rawValue {
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

public protocol BeaconPairingRequestProtocol: BeaconPairingMessageProtocol {}
