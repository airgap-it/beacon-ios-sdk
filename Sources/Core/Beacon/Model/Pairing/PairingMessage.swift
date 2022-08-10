//
//  PairingMessage.swift
//  
//
//  Created by Julia Samol on 10.08.22.
//

import Foundation

public enum BeaconPairingMessage: Codable, Hashable, BeaconPairingMessageProtocol {
    case request(BeaconPairingRequest)
    case response(BeaconPairingResponse)
    
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
    
    private var common: BeaconPairingMessageProtocol {
        switch self {
        case let .request(content):
            return content
        case let .response(content):
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
        if type.hasSuffix(BeaconPairingRequest.typeSuffix) {
            self = .request(try .init(from: decoder))
        } else if type.hasSuffix(BeaconPairingResponse.typeSuffix) {
            self = .response(try .init(from: decoder))
        } else {
            throw Beacon.Error.unknownMessageType(type, version: Beacon.Configuration.beaconVersion)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .request(content):
            try content.encode(to: encoder)
        case let .response(content):
            try content.encode(to: encoder)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type
    }
}

// MARK: Protocol

public protocol BeaconPairingMessageProtocol {
    var id: String { get }
    var name: String { get }
    var version: String { get }
    var publicKey: String { get }
    
    func toPeer() -> Beacon.Peer
}
