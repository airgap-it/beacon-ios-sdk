//
//  BlockchainV3TezosResponse.swift
//  
//
//  Created by Julia Samol on 05.01.22.
//

import Foundation
import BeaconCore

public enum BlockchainV3TezosResponse: BlockchainV3BeaconResponseContentDataProtocol, Equatable, Codable {
    case operation(OperationV3TezosResponse)
    case signPayload(SignPayloadV3TezosResponse)
    case broadcast(BroadcastV3TezosResponse)

    // MARK: BeaconMessage Compatibility

    public init(from blockchainResponse: BlockchainBeaconResponseProtocol) throws {
        guard let blockchainResponse = blockchainResponse as? BlockchainTezosResponse else {
            throw Beacon.Error.unknownBeaconMessage
        }
        
        switch blockchainResponse {
        case let .operation(content):
            self = .operation(OperationV3TezosResponse(from: content))
        case let .signPayload(content):
            self = .signPayload(SignPayloadV3TezosResponse(from: content))
        case let .broadcast(content):
            self = .broadcast(BroadcastV3TezosResponse(from: content))
        }
    }

    public func toBeaconMessage<T: Blockchain>(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        blockchainIdentifier: String,
        using storageManager: StorageManager,
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    ) {
        switch self {
        case let .operation(content):
            content.toBeaconMessage(
                id: id,
                version: version,
                senderID: senderID,
                origin: origin,
                blockchainIdentifier: blockchainIdentifier,
                using: storageManager,
                completion: completion
            )
        case let .signPayload(content):
            content.toBeaconMessage(
                id: id,
                version: version,
                senderID: senderID,
                origin: origin,
                blockchainIdentifier: blockchainIdentifier,
                using: storageManager,
                completion: completion
            )
        case let .broadcast(content):
            content.toBeaconMessage(
                id: id,
                version: version,
                senderID: senderID,
                origin: origin,
                blockchainIdentifier: blockchainIdentifier,
                using: storageManager,
                completion: completion
            )
        }
    }

    // MARK: Equatable

    public func equals(_ other: BlockchainV3BeaconResponseContentDataProtocol) -> Bool {
        guard let other = other as? BlockchainV3TezosResponse else {
            return false
        }
        
        return self == other
    }

    // MARK: Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case OperationV3TezosResponse.type:
            self = .operation(try OperationV3TezosResponse(from: decoder))
        case SignPayloadV3TezosResponse.type:
            self = .signPayload(try SignPayloadV3TezosResponse(from: decoder))
        case BroadcastV3TezosResponse.type:
            self = .broadcast(try BroadcastV3TezosResponse(from: decoder))
        default:
            throw Beacon.Error.unknownMessageType(type, version: "3")
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .operation(content):
            try content.encode(to: encoder)
        case let .signPayload(content):
            try content.encode(to: encoder)
        case let .broadcast(content):
            try content.encode(to: encoder)
        }
    }

    // MARK: Types

    enum CodingKeys: String, CodingKey {
        case type
    }
}
