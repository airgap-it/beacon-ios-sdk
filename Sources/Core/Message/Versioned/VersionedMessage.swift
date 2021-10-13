//
//  VersionedMessage.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
public enum VersionedBeaconMessage: VersionedBeaconMessageProtocol, Equatable, Codable {
    
    case v1(V1BeaconMessage)
    case v2(V2BeaconMessage)
    
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>, senderID: String) throws {
        switch beaconMessage.version.major {
        case "1":
            self = .v1(try V1BeaconMessage(from: beaconMessage, senderID: senderID))
        case "2":
            self = .v2(try V2BeaconMessage(from: beaconMessage, senderID: senderID))
        default:
            // fallback to the newest version
            self = .v2(try V2BeaconMessage(from: beaconMessage, senderID: senderID))
        }
    }
    
    init(from disconnectMessage: DisconnectBeaconMessage, senderID: String) throws {
        switch disconnectMessage.version.major {
        case "1":
            self = .v1(try V1BeaconMessage(from: disconnectMessage, senderID: senderID))
        case "2":
            self = .v2(try V2BeaconMessage(from: disconnectMessage, senderID: senderID))
        default:
            // fallback to the newest version
            self = .v2(try V2BeaconMessage(from: disconnectMessage, senderID: senderID))
        }
    }
    
    public func toBeaconMessage<T: Blockchain>(
        with origin: Beacon.Origin,
        using storageManager: StorageManager,
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    ) {
        common.toBeaconMessage(with: origin, using: storageManager, completion: completion)
    }
    
    // MARK: Attributes
    
    public var type: String { common.type }
    public var version: String { common.version }
    public var id: String { common.id }
    
    private var common: VersionedBeaconMessageProtocol {
        switch self {
        case let .v1(content):
            return content
        case let .v2(content):
            return content
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
        default:
            // fallback to the newest version
            self = .v2(try V2BeaconMessage(from: decoder))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .v1(content):
            try content.encode(to: encoder)
        case let .v2(content):
            try content.encode(to: encoder)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case version
    }
}

// MARK: Protocol

public protocol VersionedBeaconMessageProtocol {
    var type: String { get }
    var version: String { get }
    var id: String { get }
    
    init<T: Blockchain>(from beaconMessage: BeaconMessage<T>, senderID: String) throws
    
    func toBeaconMessage<T: Blockchain>(
        with origin: Beacon.Origin,
        using storageManager: StorageManager,
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    )
}

// MARK: Extensions

private extension String {
    
    var major: String {
        prefix(before: ".")
    }
}
