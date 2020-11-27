//
//  VersionedMessage.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Message {
    
    enum Versioned: Codable {
        case v1(V1)
        case v2(V2)
        
        // MARK: BeaconMessage Compatibility
        
        init(from beaconMessage: Beacon.Message, version: String, senderID: String) {
            switch version.major {
            case "1":
                self = .v1(V1(from: beaconMessage, version: version, senderID: senderID))
            case "2":
                self = .v2(V2(from: beaconMessage, version: version, senderID: senderID))
            default:
                // fallback to the newest version
                self = .v2(V2(from: beaconMessage, version: version, senderID: senderID))
            }
        }
        
        func toBeaconMessage(
            with origin: Beacon.Origin,
            using storage: StorageManager,
            completion: @escaping (Result<Beacon.Message, Error>) -> ()
        ) {
            switch self {
            case let .v1(content):
                content.toBeaconMessage(with: origin, using: storage, completion: completion)
            case let .v2(content):
                content.toBeaconMessage(with: origin, using: storage, completion: completion)
            }
        }
        
        // MARK: Attributes
        
        var version: String {
            switch self {
            case let .v1(content):
                return content.version
            case let .v2(content):
                return content.version
            }
        }
        
        var identifer: String {
            switch self {
            case let .v1(content):
                return content.identifier
            case let .v2(content):
                return content.identifier
            }
        }
        
        func comesFrom(appMetadata: Beacon.AppMetadata) -> Bool {
            switch self {
            case let .v1(content):
                return content.comesFrom(appMetadata: appMetadata)
            case let .v2(content):
                return content.comesFrom(appMetadata: appMetadata)
            }
        }
        
        // MARK: Codable
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let version = try container.decode(String.self, forKey: .version)
            switch version.major {
            case "1":
                self = .v1(try V1(from: decoder))
            case "2":
                self = .v2(try V2(from: decoder))
            default:
                // fallback to the newest version
                self = .v2(try V2(from: decoder))
            }
        }
        
        func encode(to encoder: Encoder) throws {
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
}

// MARK: Extensions

extension String {
    
    var major: String {
        substring(before: ".")
    }
}
