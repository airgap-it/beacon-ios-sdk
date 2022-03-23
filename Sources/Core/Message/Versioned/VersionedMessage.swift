//
//  VersionedMessage.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
public enum VersionedBeaconMessage<BlockchainType: Blockchain>: VersionedBeaconMessageProtocol {
    
    case v1(V1BeaconMessage<BlockchainType>)
    case v2(V2BeaconMessage<BlockchainType>)
    case v3(V3BeaconMessage<BlockchainType>)
    
    // MARK: BeaconMessage Compatibility
    
    public init(from beaconMessage: BeaconMessage<BlockchainType>, senderID: String) throws {
        switch beaconMessage.version.major {
        case "1":
            self = .v1(try V1BeaconMessage(from: beaconMessage, senderID: senderID))
        case "2":
            self = .v2(try V2BeaconMessage(from: beaconMessage, senderID: senderID))
        case "3":
            self = .v3(try V3BeaconMessage(from: beaconMessage, senderID: senderID))
        default:
            // fallback to the newest version
            self = .v3(try V3BeaconMessage(from: beaconMessage, senderID: senderID))
        }
    }
    
    init(from disconnectMessage: DisconnectBeaconMessage, senderID: String) throws {
        switch disconnectMessage.version.major {
        case "1":
            self = .v1(try V1BeaconMessage(from: disconnectMessage, senderID: senderID))
        case "2":
            self = .v2(try V2BeaconMessage(from: disconnectMessage, senderID: senderID))
        case "3":
            self = .v3(try V3BeaconMessage(from: disconnectMessage, senderID: senderID))
        default:
            // fallback to the newest version
            self = .v3(try V3BeaconMessage(from: disconnectMessage, senderID: senderID))
        }
    }
    
    public func toBeaconMessage(
        with origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<BlockchainType>, Error>) -> ()
    ) {
        switch self {
        case let .v1(content):
            content.toBeaconMessage(with: origin, completion: completion)
        case let .v2(content):
            content.toBeaconMessage(with: origin, completion: completion)
        case let .v3(content):
            content.toBeaconMessage(with: origin, completion: completion)
        }
    }
    
    // MARK: Attributes
    
    public var version: String {
        switch self {
        case let .v1(content):
            return content.version
        case let .v2(content):
            return content.version
        case let .v3(content):
            return content.version
        }
    }
    
    // MARK: Codable
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(String.self, forKey: .version)
        switch version.major {
        case "1":
            self = .v1(try V1BeaconMessage(from: decoder))
        case "2":
            self = .v2(try V2BeaconMessage(from: decoder))
        case "3":
            self = .v3(try V3BeaconMessage(from: decoder))
        default:
            // fallback to the newest version
            self = .v3(try V3BeaconMessage(from: decoder))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .v1(content):
            try content.encode(to: encoder)
        case let .v2(content):
            try content.encode(to: encoder)
        case let .v3(content):
            try content.encode(to: encoder)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case version
    }
}

// MARK: Protocol

public protocol VersionedBeaconMessageProtocol: Codable, Equatable {
    associatedtype BlockchainType: Blockchain
    
    var version: String { get }
    
    init(from beaconMessage: BeaconMessage<BlockchainType>, senderID: String) throws
    func toBeaconMessage(
        with origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<BlockchainType>, Error>) -> ()
    )
}

// MARK: Extensions

private extension String {
    
    var major: String {
        prefix(before: ".")
    }
}
