//
//  V1TezosMessage.swift
//  
//
//  Created by Julia Samol on 28.09.21.
//

import Foundation
import BeaconCore
    
public enum V1TezosMessage: BlockchainV1Message {
    case permissionRequest(PermissionV1TezosRequest)
    case operationRequest(OperationV1TezosRequest)
    case signPayloadRequest(SignPayloadV1TezosRequest)
    case broadcastRequest(BroadcastV1TezosRequest)
    case permissionResponse(PermissionV1TezosResponse)
    case operationResponse(OperationV1TezosResponse)
    case signPayloadResponse(SignPayloadV1TezosResponse)
    case broadcastResponse(BroadcastV1TezosResponse)
    
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>, senderID: String) throws {
        guard let beaconMessage = beaconMessage as? BeaconMessage<Tezos> else {
            throw Beacon.Error.unknownBeaconMessage
        }
        
        switch beaconMessage {
        case let .request(request):
            switch request {
            case let .permission(content):
                self = .permissionRequest(PermissionV1TezosRequest(from: content, senderID: senderID))
            case let .blockchain(blockchain):
                switch blockchain {
                case let .operation(content):
                    self = .operationRequest(OperationV1TezosRequest(from: content, senderID: senderID))
                case let .signPayload(content):
                    self = .signPayloadRequest(SignPayloadV1TezosRequest(from: content, senderID: senderID))
                case let .broadcast(content):
                    self = .broadcastRequest(BroadcastV1TezosRequest(from: content, senderID: senderID))
                }
            }
        case let .response(response):
            switch response {
            case let .permission(content):
                self = .permissionResponse(PermissionV1TezosResponse(from: content, senderID: senderID))
            case let .blockchain(blockchain):
                switch blockchain {
                case let .operation(content):
                    self = .operationResponse(OperationV1TezosResponse(from: content, senderID: senderID))
                case let.signPayload(content):
                    self = .signPayloadResponse(SignPayloadV1TezosResponse(from: content, senderID: senderID))
                case let .broadcast(content):
                    self = .broadcastResponse(BroadcastV1TezosResponse(from: content, senderID: senderID))
                }
            default:
                throw Beacon.Error.messageNotSupportedInVersion(message: beaconMessage, version: beaconMessage.version)
            }
        default:
            throw Beacon.Error.messageNotSupportedInVersion(message: beaconMessage, version: beaconMessage.version)
        }
    }
    
    public func toBeaconMessage<T: Blockchain>(
        with origin: Beacon.Origin,
        using storageManager: StorageManager,
        completion: @escaping (Result<BeaconMessage<T>, Swift.Error>) -> ()
    ) {
        common.toBeaconMessage(with: origin, using: storageManager, completion: completion)
    }
    
    // MARK: Attributes
    
    public var type: String { common.type }
    public var version: String { common.version }
    public var id: String { common.id }
    
    private var common: V1BeaconMessageProtocol {
        switch self {
        case let .permissionRequest(content):
            return content
        case let .operationRequest(content):
            return content
        case let .signPayloadRequest(content):
            return content
        case let .broadcastRequest(content):
            return content
        case let .permissionResponse(content):
            return content
        case let .operationResponse(content):
            return content
        case let .signPayloadResponse(content):
            return content
        case let .broadcastResponse(content):
            return content
        }
    }
    
    // MARK: Codable
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case PermissionV1TezosRequest.type:
            self = .permissionRequest(try PermissionV1TezosRequest(from: decoder))
        case OperationV1TezosRequest.type:
            self = .operationRequest(try OperationV1TezosRequest(from: decoder))
        case SignPayloadV1TezosRequest.type:
            self = .signPayloadRequest(try SignPayloadV1TezosRequest(from: decoder))
        case BroadcastV1TezosRequest.type:
            self = .broadcastRequest(try BroadcastV1TezosRequest(from: decoder))
        case PermissionV1TezosResponse.type:
            self = .permissionResponse(try PermissionV1TezosResponse(from: decoder))
        case OperationV1TezosResponse.type:
            self = .operationResponse(try OperationV1TezosResponse(from: decoder))
        case SignPayloadV1TezosResponse.type:
            self = .signPayloadResponse(try SignPayloadV1TezosResponse(from: decoder))
        case BroadcastV1TezosResponse.type:
            self = .broadcastResponse(try BroadcastV1TezosResponse(from: decoder))
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
