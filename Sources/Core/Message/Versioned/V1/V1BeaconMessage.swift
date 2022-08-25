//
//  V1BeaconMessage.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
public enum V1BeaconMessage<BlockchainType: Blockchain>: V1BeaconMessageProtocol {
    public static var version: String { "1" }
    
    public typealias BlockchainBeaconMessage = BlockchainType.VersionedMessage.V1
    
    case errorResponse(ErrorV1BeaconResponse<BlockchainType>)
    case disconnectMessage(DisconnectV1BeaconMessage<BlockchainType>)
    case blockchainMessage(BlockchainBeaconMessage)
    
    // MARK: BeaconMessage Compatibility
    
    public init(from beaconMessage: BeaconMessage<BlockchainType>, senderID: String) throws {
        switch beaconMessage {
        case let .response(response):
            switch response {
            case let .acknowledge(content):
                throw Beacon.Error.messageNotSupportedInVersion(message: beaconMessage, version: content.version)
            case let .error(content):
                self = .errorResponse(ErrorV1BeaconResponse(from: content, senderID: senderID))
            default:
                self = .blockchainMessage(try BlockchainBeaconMessage(from: beaconMessage, senderID: senderID))
            }
        case let .disconnect(content):
            self = .disconnectMessage(DisconnectV1BeaconMessage(from: content, senderID: senderID))
        default:
            self = .blockchainMessage(try BlockchainBeaconMessage(from: beaconMessage, senderID: senderID))
        }
    }
    
    init(from disconnectMessage: DisconnectBeaconMessage, senderID: String) throws {
        self = .disconnectMessage(DisconnectV1BeaconMessage(from: disconnectMessage, senderID: senderID))
    }
    
    public func toBeaconMessage(
        withOrigin origin: Beacon.Connection.ID,
        andDestination destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<BlockchainType>, Error>) -> ()
    ) {
        switch self {
        case let .errorResponse(content):
            content.toBeaconMessage(withOrigin: origin, andDestination: destination, completion: completion)
        case let .disconnectMessage(content):
            content.toBeaconMessage(withOrigin: origin, andDestination: destination, completion: completion)
        case let .blockchainMessage(content):
            content.toBeaconMessage(withOrigin: origin, andDestination: destination, completion: completion)
        }
    }
    
    // MARK: Attributes
    
    public var type: String {
        switch self {
        case let .errorResponse(content):
            return content.type
        case let .disconnectMessage(content):
            return content.type
        case let .blockchainMessage(content):
            return content.type
        }
    }
    public var version: String {
        switch self {
        case let .errorResponse(content):
            return content.version
        case let .disconnectMessage(content):
            return content.version
        case let .blockchainMessage(content):
            return content.version
        }
    }
    public var id: String {
        switch self {
        case let .errorResponse(content):
            return content.id
        case let .disconnectMessage(content):
            return content.id
        case let .blockchainMessage(content):
            return content.id
        }
    }
    
    // MARK: Codable
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case ErrorV1BeaconResponse<BlockchainType>.type:
            self = .errorResponse(try ErrorV1BeaconResponse(from: decoder))
        case DisconnectV1BeaconMessage<BlockchainType>.type:
            self = .disconnectMessage(try DisconnectV1BeaconMessage(from: decoder))
        default:
            self = .blockchainMessage(try BlockchainBeaconMessage(from: decoder))
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

public protocol V1BeaconMessageProtocol: VersionedBeaconMessageProtocol, Identifiable {
    var id: String { get }
    var type: String { get }
}
