//
//  V2BeaconMessage.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
public enum V2BeaconMessage<BlockchainType: Blockchain>: V2BeaconMessageProtocol {
    public static var version: String { "2" }
    
    public typealias BlockchainBeaconMessage = BlockchainType.VersionedMessage.V2
    
    case acknowledgeResponse(AcknowledgeV2BeaconResponse<BlockchainType>)
    case errorResponse(ErrorV2BeaconResponse<BlockchainType>)
    case disconnectMessage(DisconnectV2BeaconMessage<BlockchainType>)
    case blockchainMessage(BlockchainBeaconMessage)
    
    
    // MARK: BeaconMessage Compatibility
    
    public init(from beaconMessage: BeaconMessage<BlockchainType>, senderID: String) throws {
        switch beaconMessage {
        case let .response(response):
            switch response {
            case let .acknowledge(content):
                self = .acknowledgeResponse(AcknowledgeV2BeaconResponse(from: content, senderID: senderID))
            case let .error(content):
                self = .errorResponse(ErrorV2BeaconResponse(from: content, senderID: senderID))
            default:
                self = .blockchainMessage(try BlockchainBeaconMessage(from: beaconMessage, senderID: senderID))
            }
        case let .disconnect(content):
            self = .disconnectMessage(DisconnectV2BeaconMessage(from: content, senderID: senderID))
        default:
            self = .blockchainMessage(try BlockchainBeaconMessage(from: beaconMessage, senderID: senderID))
        }
    }
    
    init(from disconnectMessage: DisconnectBeaconMessage, senderID: String) throws {
        self = .disconnectMessage(DisconnectV2BeaconMessage(from: disconnectMessage, senderID: senderID))
    }
    
    public func toBeaconMessage(
        withOrigin origin: Beacon.Connection.ID,
        andDestination destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<BlockchainType>, Error>) -> ()
    ) {
        switch self {
        case let .acknowledgeResponse(content):
            content.toBeaconMessage(withOrigin: origin, andDestination: destination, completion: completion)
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
        case let .acknowledgeResponse(content):
            return content.type
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
        case let .acknowledgeResponse(content):
            return content.version
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
        case let .acknowledgeResponse(content):
            return content.id
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
        case AcknowledgeV2BeaconResponse<BlockchainType>.type:
            self = .acknowledgeResponse(try AcknowledgeV2BeaconResponse(from: decoder))
        case ErrorV2BeaconResponse<BlockchainType>.type:
            self = .errorResponse(try ErrorV2BeaconResponse(from: decoder))
        case DisconnectV2BeaconMessage<BlockchainType>.type:
            self = .disconnectMessage(try DisconnectV2BeaconMessage(from: decoder))
        default:
            self = .blockchainMessage(try BlockchainBeaconMessage(from: decoder))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .acknowledgeResponse(content):
            try content.encode(to: encoder)
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

public protocol V2BeaconMessageProtocol: VersionedBeaconMessageProtocol, Identifiable {
    var id: String { get }
    var type: String { get }
}
