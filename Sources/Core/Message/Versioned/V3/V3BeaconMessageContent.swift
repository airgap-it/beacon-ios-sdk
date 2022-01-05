//
//  V3BeaconMessageContent.swift
//  
//
//  Created by Julia Samol on 04.01.22.
//

import Foundation

public extension V3BeaconMessage {
    
    enum Content: V3BeaconMessageContentProtocol, Equatable, Codable {
        
        case permissionRequest(PermissionV3BeaconRequestContent)
        case blockchainRequest(BlockchainV3BeaconRequestContent)
        case permissionResponse(PermissionV3BeaconResponseContent)
        case blockchainResponse(BlockchainV3BeaconResponseContent)
        case acknowledgeResponse(AcknowledgeV3BeaconResponseContent)
        case errorResponse(ErrorV3BeaconResponseContent)
        case disconnectMessage(DisconnectV3BeaconMessageContent)
        
        // MARK: BeaconMessage Compatibility
        
        public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>) throws {
            switch beaconMessage {
            case let .request(request):
                switch request {
                case let .permission(content):
                    self = .permissionRequest(try PermissionV3BeaconRequestContent(from: content, ofType: T.self))
                case let .blockchain(content):
                    self = .blockchainRequest(try BlockchainV3BeaconRequestContent(from: content, ofType: T.self))
                }
            case let .response(response):
                switch response {
                case let .permission(content):
                    self = .permissionResponse(try PermissionV3BeaconResponseContent(from: content, ofType: T.self))
                case let .blockchain(content):
                    self = .blockchainResponse(try BlockchainV3BeaconResponseContent(from: content, ofType: T.self))
                case let .acknowledge(content):
                    self = .acknowledgeResponse(AcknowledgeV3BeaconResponseContent(from: content))
                case let .error(content):
                    self = .errorResponse(ErrorV3BeaconResponseContent(from: content))
                }
            case let .disconnect(content):
                self = .disconnectMessage(DisconnectV3BeaconMessageContent(from: content))
            }
        }
        
        public func toBeaconMessage<T: Blockchain>(
            id: String,
            version: String,
            senderID: String,
            origin: Beacon.Origin,
            using storageManager: StorageManager,
            completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
        ) {
            common.toBeaconMessage(id: id, version: version, senderID: senderID, origin: origin, using: storageManager, completion: completion)
        }
        
        // MARK: Attributes
        
        public var type: String { common.type }
        
        private var common: V3BeaconMessageContentProtocol {
            switch self {
            case let .permissionRequest(content):
                return content
            case let .blockchainRequest(content):
                return content
            case let .permissionResponse(content):
                return content
            case let .blockchainResponse(content):
                return content
            case let .acknowledgeResponse(content):
                return content
            case let .errorResponse(content):
                return content
            case let .disconnectMessage(content):
                return content
            }
        }
        
        // MARK: Codable
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            switch type {
            case PermissionV3BeaconRequestContent.type:
                self = .permissionRequest(try PermissionV3BeaconRequestContent(from: decoder))
            case BlockchainV3BeaconRequestContent.type:
                self = .blockchainRequest(try BlockchainV3BeaconRequestContent(from: decoder))
            case PermissionV3BeaconResponseContent.type:
                self = .permissionResponse(try PermissionV3BeaconResponseContent(from: decoder))
            case BlockchainV3BeaconResponseContent.type:
                self = .blockchainResponse(try BlockchainV3BeaconResponseContent(from: decoder))
            case AcknowledgeV3BeaconResponseContent.type:
                self = .acknowledgeResponse(try AcknowledgeV3BeaconResponseContent(from: decoder))
            case ErrorV3BeaconResponseContent.type:
                self = .errorResponse(try ErrorV3BeaconResponseContent(from: decoder))
            case DisconnectV3BeaconMessageContent.type:
                self = .disconnectMessage(try DisconnectV3BeaconMessageContent(from: decoder))
            default:
                throw Beacon.Error.unknownMessageType(type, version: "3")
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            switch self {
            case let .permissionRequest(content):
                try content.encode(to: encoder)
            case let .blockchainRequest(content):
                try content.encode(to: encoder)
            case let .permissionResponse(content):
                try content.encode(to: encoder)
            case let .blockchainResponse(content):
                try content.encode(to: encoder)
            case let .acknowledgeResponse(content):
                try content.encode(to: encoder)
            case let .errorResponse(content):
                try content.encode(to: encoder)
            case let .disconnectMessage(content):
                try content.encode(to: encoder)
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case type
        }
    }
}

// MARK: Protocol

public protocol V3BeaconMessageContentProtocol {
    var type: String { get }
    
    init<T: Blockchain>(from beaconMessage: BeaconMessage<T>) throws
    
    func toBeaconMessage<T: Blockchain>(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        using storageManager: StorageManager,
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    )
}
