//
//  V2BeaconMessage.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
public enum V2BeaconMessage: V2BeaconMessageProtocol, Equatable, Codable {
    
    case acknowledgeResponse(AcknowledgeV2BeaconResponse)
    case errorResponse(ErrorV2BeaconResponse)
    case disconnectMessage(DisconnectV2BeaconMessage)
    case blockchainMessage(V2BeaconMessageProtocol & Codable)
    
    
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>, senderID: String) throws {
        switch beaconMessage {
        case let .response(response):
            switch response {
            case let .acknowledge(content):
                self = .acknowledgeResponse(AcknowledgeV2BeaconResponse(from: content, senderID: senderID))
            case let .error(content):
                self = .errorResponse(ErrorV2BeaconResponse(from: content, senderID: senderID))
            default:
                self = .blockchainMessage(try T.VersionedMessage.V2(from: beaconMessage, senderID: senderID))
            }
        case let .disconnect(content):
            self = .disconnectMessage(DisconnectV2BeaconMessage(from: content, senderID: senderID))
        default:
            self = .blockchainMessage(try T.VersionedMessage.V2(from: beaconMessage, senderID: senderID))
        }
    }
    
    init(from disconnectMessage: DisconnectBeaconMessage, senderID: String) throws {
        self = .disconnectMessage(DisconnectV2BeaconMessage(from: disconnectMessage, senderID: senderID))
    }
    
    public func toBeaconMessage<T: Blockchain>(
        with origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    ) {
        common.toBeaconMessage(with: origin, completion: completion)
    }
    
    // MARK: Attributes
    
    public var type: String { common.type }
    public var version: String { common.version }
    public var id: String { common.id }
    
    private var common: V2BeaconMessageProtocol {
        switch self {
        case let .acknowledgeResponse(content):
            return content
        case let .errorResponse(content):
            return content
        case let .disconnectMessage(content):
            return content
        case let .blockchainMessage(content):
            return content
        }
    }
    
    // MARK: Equatable
    
    public static func == (lhs: V2BeaconMessage, rhs: V2BeaconMessage) -> Bool {
        switch (lhs, rhs) {
        case let (.acknowledgeResponse(lhs), .acknowledgeResponse(rhs)):
            return lhs == rhs
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
        case AcknowledgeV2BeaconResponse.type:
            self = .acknowledgeResponse(try AcknowledgeV2BeaconResponse(from: decoder))
        case ErrorV2BeaconResponse.type:
            self = .errorResponse(try ErrorV2BeaconResponse(from: decoder))
        case DisconnectV2BeaconMessage.type:
            self = .disconnectMessage(try DisconnectV2BeaconMessage(from: decoder))
        default:
            let blockchain = try compat().versioned().blockchain()
            self = .blockchainMessage(try blockchain.decoder.v2.message(from: decoder))
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

public protocol V2BeaconMessageProtocol: VersionedBeaconMessageProtocol {
    var id: String { get }
    var type: String { get }
}
