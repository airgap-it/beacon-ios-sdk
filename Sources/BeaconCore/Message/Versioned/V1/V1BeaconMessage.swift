//
//  V1BeaconMessage.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
public enum V1BeaconMessage: V1BeaconMessageProtocol, Equatable, Codable {
    
    case errorResponse(ErrorV1BeaconResponse)
    case disconnectMessage(DisconnectV1BeaconMessage)
    case blockchainMessage(V1BeaconMessageProtocol & Codable)
    
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>, senderID: String) throws {
        switch beaconMessage {
        case let .response(response):
            switch response {
            case let .acknowledge(content):
                throw Beacon.Error.messageNotSupportedInVersion(message: beaconMessage, version: content.version)
            case let .error(content):
                self = .errorResponse(ErrorV1BeaconResponse(from: content, senderID: senderID))
            default:
                self = .blockchainMessage(try T.VersionedMessage.V1(from: beaconMessage, senderID: senderID))
            }
        case let .disconnect(content):
            self = .disconnectMessage(DisconnectV1BeaconMessage(from: content, senderID: senderID))
        default:
            self = .blockchainMessage(try T.VersionedMessage.V1(from: beaconMessage, senderID: senderID))
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
    
    private var common: V1BeaconMessageProtocol {
        switch self {
        case let .errorResponse(content):
            return content
        case let .disconnectMessage(content):
            return content
        case let .blockchainMessage(content):
            return content
        }
    }
    
    // MARK: Equatable
    
    public static func == (lhs: V1BeaconMessage, rhs: V1BeaconMessage) -> Bool {
        switch (lhs, rhs) {
        case let (.errorResponse(lhs), .errorResponse(rhs)):
            return lhs == rhs
        case let (.disconnectMessage(lhs), .disconnectMessage(rhs)):
            return lhs == rhs
        case let (.blockchainMessage(lhs), .blockchainMessage(rhs)):
            return lhs.id == rhs.id && lhs.version == rhs.version && lhs.type == rhs.type
        default:
            return false
        }
    }
    
    // MARK: Codable
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case ErrorV1BeaconResponse.type:
            self = .errorResponse(try ErrorV1BeaconResponse(from: decoder))
        case DisconnectV1BeaconMessage.type:
            self = .disconnectMessage(try DisconnectV1BeaconMessage(from: decoder))
        default:
            guard let compat = Compat.shared else {
                throw Beacon.Error.uninitialized
            }
            
            let blockchain = try compat.versioned().blockchain()
            self = .blockchainMessage(try blockchain.decoder.v1(from: decoder))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .errorResponse(content):
            try content.encode(to: encoder)
        case let .disconnectMessage(content):
            try content.encode(to: encoder)
        case let .blockchainMessage(content):
            try content.encode(to: encoder)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type
    }
}

// MARK: Protocol

public protocol V1BeaconMessageProtocol: VersionedBeaconMessageProtocol {}
