//
//  V2TezosMessage.swift
//  
//
//  Created by Julia Samol on 29.09.21.
//

import Foundation
import BeaconCore
    
public enum V2TezosMessage: BlockchainV2Message {
    case permissionRequest(PermissionV2TezosRequest)
    case operationRequest(OperationV2TezosRequest)
    case signPayloadRequest(SignPayloadV2TezosRequest)
    case broadcastRequest(BroadcastV2TezosRequest)
    case permissionResponse(PermissionV2TezosResponse)
    case operationResponse(OperationV2TezosResponse)
    case signPayloadResponse(SignPayloadV2TezosResponse)
    case broadcastResponse(BroadcastV2TezosResponse)
    
    // MARK: BeaconMessage Compatibility
    
    public init(from beaconMessage: BeaconMessage<Tezos>, senderID: String) throws {
        switch beaconMessage {
        case let .request(request):
            switch request {
            case let .permission(content):
                self = .permissionRequest(PermissionV2TezosRequest(from: content, senderID: senderID))
            case let .blockchain(blockchain):
                switch blockchain {
                case let .operation(content):
                    self = .operationRequest(OperationV2TezosRequest(from: content, senderID: senderID))
                case let .signPayload(content):
                    self = .signPayloadRequest(SignPayloadV2TezosRequest(from: content, senderID: senderID))
                case let .broadcast(content):
                    self = .broadcastRequest(BroadcastV2TezosRequest(from: content, senderID: senderID))
                }
            }
        case let .response(response):
            switch response {
            case let .permission(content):
                self = .permissionResponse(PermissionV2TezosResponse(from: content, senderID: senderID))
            case let .blockchain(blockchain):
                switch blockchain {
                case let .operation(content):
                    self = .operationResponse(OperationV2TezosResponse(from: content, senderID: senderID))
                case let.signPayload(content):
                    self = .signPayloadResponse(SignPayloadV2TezosResponse(from: content, senderID: senderID))
                case let .broadcast(content):
                    self = .broadcastResponse(BroadcastV2TezosResponse(from: content, senderID: senderID))
                }
            default:
                throw Beacon.Error.messageNotSupportedInVersion(message: beaconMessage, version: beaconMessage.version)
            }
        default:
            throw Beacon.Error.messageNotSupportedInVersion(message: beaconMessage, version: beaconMessage.version)
        }
    }
    
    public func toBeaconMessage(
        with origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<Tezos>, Swift.Error>) -> ()
    ) {
        switch self {
        case let .permissionRequest(content):
            content.toBeaconMessage(with: origin, completion: completion)
        case let .operationRequest(content):
            content.toBeaconMessage(with: origin, completion: completion)
        case let .signPayloadRequest(content):
            content.toBeaconMessage(with: origin, completion: completion)
        case let .broadcastRequest(content):
            content.toBeaconMessage(with: origin, completion: completion)
        case let .permissionResponse(content):
            content.toBeaconMessage(with: origin, completion: completion)
        case let .operationResponse(content):
            content.toBeaconMessage(with: origin, completion: completion)
        case let .signPayloadResponse(content):
            content.toBeaconMessage(with: origin, completion: completion)
        case let .broadcastResponse(content):
            content.toBeaconMessage(with: origin, completion: completion)
        }
    }
    
    // MARK: Attributes
    
    public var type: String {
        switch self {
        case let .permissionRequest(content):
            return content.type
        case let .operationRequest(content):
            return content.type
        case let .signPayloadRequest(content):
            return content.type
        case let .broadcastRequest(content):
            return content.type
        case let .permissionResponse(content):
            return content.type
        case let .operationResponse(content):
            return content.type
        case let .signPayloadResponse(content):
            return content.type
        case let .broadcastResponse(content):
            return content.type
        }
    }
    
    public var version: String {
        switch self {
        case let .permissionRequest(content):
            return content.version
        case let .operationRequest(content):
            return content.version
        case let .signPayloadRequest(content):
            return content.version
        case let .broadcastRequest(content):
            return content.version
        case let .permissionResponse(content):
            return content.version
        case let .operationResponse(content):
            return content.version
        case let .signPayloadResponse(content):
            return content.version
        case let .broadcastResponse(content):
            return content.version
        }
    }
    
    public var id: String {
        switch self {
        case let .permissionRequest(content):
            return content.id
        case let .operationRequest(content):
            return content.id
        case let .signPayloadRequest(content):
            return content.id
        case let .broadcastRequest(content):
            return content.id
        case let .permissionResponse(content):
            return content.id
        case let .operationResponse(content):
            return content.id
        case let .signPayloadResponse(content):
            return content.id
        case let .broadcastResponse(content):
            return content.id
        }
    }
    
    // MARK: Codable
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case PermissionV2TezosRequest.type:
            self = .permissionRequest(try PermissionV2TezosRequest(from: decoder))
        case OperationV2TezosRequest.type:
            self = .operationRequest(try OperationV2TezosRequest(from: decoder))
        case SignPayloadV2TezosRequest.type:
            self = .signPayloadRequest(try SignPayloadV2TezosRequest(from: decoder))
        case BroadcastV2TezosRequest.type:
            self = .broadcastRequest(try BroadcastV2TezosRequest(from: decoder))
        case PermissionV2TezosResponse.type:
            self = .permissionResponse(try PermissionV2TezosResponse(from: decoder))
        case OperationV2TezosResponse.type:
            self = .operationResponse(try OperationV2TezosResponse(from: decoder))
        case SignPayloadV2TezosResponse.type:
            self = .signPayloadResponse(try SignPayloadV2TezosResponse(from: decoder))
        case BroadcastV2TezosResponse.type:
            self = .broadcastResponse(try BroadcastV2TezosResponse(from: decoder))
        default:
            let version = try container.decode(String.self, forKey: .version)
            throw Beacon.Error.unknownMessageType(type, version: version)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .permissionRequest(content):
            try content.encode(to: encoder)
        case let .operationRequest(content):
            try content.encode(to: encoder)
        case let .signPayloadRequest(content):
            try content.encode(to: encoder)
        case let .broadcastRequest(content):
            try content.encode(to: encoder)
        case let .permissionResponse(content):
            try content.encode(to: encoder)
        case let .operationResponse(content):
            try content.encode(to: encoder)
        case let .signPayloadResponse(content):
            try content.encode(to: encoder)
        case let .broadcastResponse(content):
            try content.encode(to: encoder)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case version
    }
}
