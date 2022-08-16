//
//  V3BeaconMessageContent.swift
//  
//
//  Created by Julia Samol on 04.01.22.
//

import Foundation

public extension V3BeaconMessage {
    
    enum Content: V3BeaconMessageContentProtocol {
        public typealias PermissionRequestContentData = BlockchainType.VersionedMessage.V3.PermissionRequestContentData
        public typealias BlockchainRequestContentData = BlockchainType.VersionedMessage.V3.BlockchainRequestContentData
        public typealias PermissionResponseContentData = BlockchainType.VersionedMessage.V3.PermissionResponseContentData
        public typealias BlockchainResponseContentData = BlockchainType.VersionedMessage.V3.BlockchainResponseContentData
        
        case permissionRequest(PermissionV3BeaconRequestContent<PermissionRequestContentData>)
        case blockchainRequest(BlockchainV3BeaconRequestContent<BlockchainRequestContentData>)
        case permissionResponse(PermissionV3BeaconResponseContent<PermissionResponseContentData>)
        case blockchainResponse(BlockchainV3BeaconResponseContent<BlockchainResponseContentData>)
        case acknowledgeResponse(AcknowledgeV3BeaconResponseContent<BlockchainType>)
        case errorResponse(ErrorV3BeaconResponseContent<BlockchainType>)
        case disconnectMessage(DisconnectV3BeaconMessageContent<BlockchainType>)
        
        // MARK: BeaconMessage Compatibility
        
        public init(from beaconMessage: BeaconMessage<BlockchainType>) throws {
            switch beaconMessage {
            case let .request(request):
                switch request {
                case let .permission(content):
                    self = .permissionRequest(try PermissionV3BeaconRequestContent(from: content))
                case let .blockchain(content):
                    self = .blockchainRequest(try BlockchainV3BeaconRequestContent(from: content))
                }
            case let .response(response):
                switch response {
                case let .permission(content):
                    self = .permissionResponse(try PermissionV3BeaconResponseContent(from: content))
                case let .blockchain(content):
                    self = .blockchainResponse(try BlockchainV3BeaconResponseContent(from: content))
                case let .acknowledge(content):
                    self = .acknowledgeResponse(AcknowledgeV3BeaconResponseContent(from: content))
                case let .error(content):
                    self = .errorResponse(ErrorV3BeaconResponseContent(from: content))
                }
            case let .disconnect(content):
                self = .disconnectMessage(DisconnectV3BeaconMessageContent(from: content))
            }
        }
        
        public func toBeaconMessage(
            id: String,
            version: String,
            senderID: String,
            origin: Beacon.Connection.ID,
            destination: Beacon.Connection.ID,
            completion: @escaping (Result<BeaconMessage<BlockchainType>, Error>) -> ()
        ) {
            switch self {
            case let .permissionRequest(content):
                content.toBeaconMessage(id: id, version: version, senderID: senderID, origin: origin, destination: destination, completion: completion)
            case let .blockchainRequest(content):
                content.toBeaconMessage(id: id, version: version, senderID: senderID, origin: origin, destination: destination, completion: completion)
            case let .permissionResponse(content):
                content.toBeaconMessage(id: id, version: version, senderID: senderID, origin: origin, destination: destination, completion: completion)
            case let .blockchainResponse(content):
                content.toBeaconMessage(id: id, version: version, senderID: senderID, origin: origin, destination: destination, completion: completion)
            case let .acknowledgeResponse(content):
                content.toBeaconMessage(id: id, version: version, senderID: senderID, origin: origin, destination: destination, completion: completion)
            case let .errorResponse(content):
                content.toBeaconMessage(id: id, version: version, senderID: senderID, origin: origin, destination: destination, completion: completion)
            case let .disconnectMessage(content):
                content.toBeaconMessage(id: id, version: version, senderID: senderID, origin: origin, destination: destination, completion: completion)
            }
        }
        
        // MARK: Attributes
        
        public var type: String {
            switch self {
            case let .permissionRequest(content):
                return content.type
            case let .blockchainRequest(content):
                return content.type
            case let .permissionResponse(content):
                return content.type
            case let .blockchainResponse(content):
                return content.type
            case let .acknowledgeResponse(content):
                return content.type
            case let .errorResponse(content):
                return content.type
            case let .disconnectMessage(content):
                return content.type
            }
        }
        
        // MARK: Codable
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            switch type {
            case PermissionV3BeaconRequestContent<PermissionRequestContentData>.type:
                self = .permissionRequest(try PermissionV3BeaconRequestContent(from: decoder))
            case BlockchainV3BeaconRequestContent<BlockchainRequestContentData>.type:
                self = .blockchainRequest(try BlockchainV3BeaconRequestContent(from: decoder))
            case PermissionV3BeaconResponseContent<PermissionResponseContentData>.type:
                self = .permissionResponse(try PermissionV3BeaconResponseContent(from: decoder))
            case BlockchainV3BeaconResponseContent<BlockchainResponseContentData>.type:
                self = .blockchainResponse(try BlockchainV3BeaconResponseContent(from: decoder))
            case AcknowledgeV3BeaconResponseContent<BlockchainType>.type:
                self = .acknowledgeResponse(try AcknowledgeV3BeaconResponseContent(from: decoder))
            case ErrorV3BeaconResponseContent<BlockchainType>.type:
                self = .errorResponse(try ErrorV3BeaconResponseContent(from: decoder))
            case DisconnectV3BeaconMessageContent<BlockchainType>.type:
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

public protocol V3BeaconMessageContentProtocol: Equatable, Codable {
    associatedtype BlockchainType: Blockchain
    
    var type: String { get }
    
    init(from beaconMessage: BeaconMessage<BlockchainType>) throws
    func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Connection.ID,
        destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<BlockchainType>, Error>) -> ()
    )
}
