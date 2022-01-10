//
//  BlockchainV3SubstrateResponse.swift
//  
//
//  Created by Julia Samol on 11.01.22.
//

import Foundation
import BeaconCore

public enum BlockchainV3SubstrateResponse: BlockchainV3SubstrateResponseProtocol, Equatable, Codable {
    case transfer(TransferV3SubstrateResponse)
    case sign(SignV3SubstrateResponse)
    
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from blockchainResponse: T.Response.Blockchain, ofType type: T.Type) throws {
        guard let blockchainResponse = blockchainResponse as? BlockchainSubstrateResponse else {
            throw Beacon.Error.unknownBeaconMessage
        }
        
        switch blockchainResponse {
        case let .transfer(content):
            self = .transfer(TransferV3SubstrateResponse(from: content))
        case let .sign(content):
            self = .sign(SignV3SubstrateResponse(from: content))
        }
    }
    
    public func toBeaconMessage<T: Blockchain>(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        blockchainIdentifier: String,
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    ) {
        common.toBeaconMessage(
            id: id,
            version: version,
            senderID: senderID,
            origin: origin,
            blockchainIdentifier: blockchainIdentifier,
            completion: completion
        )
    }
    
    // MARK: Attributes
    
    public var type: String { common.type }
    
    private var common: BlockchainV3SubstrateResponseProtocol {
        switch self {
        case let .transfer(content):
            return content
        case let .sign(content):
            return content
        }
    }
    
    // MARK: Equatable
    
    public func equals(_ other: BlockchainV3BeaconResponseContentDataProtocol) -> Bool {
        guard let other = other as? BlockchainV3SubstrateResponse else {
            return false
        }
        
        return self == other
    }
    
    // MARK: Codable
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case TransferV3SubstrateResponse.type:
            self = .transfer(try TransferV3SubstrateResponse(from: decoder))
        case SignV3SubstrateResponse.type:
            self = .sign(try SignV3SubstrateResponse(from: decoder))
        default:
            throw Beacon.Error.unknownMessageType(type, version: "3")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .transfer(content):
            try content.encode(to: encoder)
        case let .sign(content):
            try content.encode(to: encoder)
        }
    }
    
    // MARK: Types
    
    enum CodingKeys: String, CodingKey {
        case type
    }
}

// MARK: Protocol

public protocol BlockchainV3SubstrateResponseProtocol: BlockchainV3BeaconResponseContentDataProtocol {
    var type: String { get }
}
