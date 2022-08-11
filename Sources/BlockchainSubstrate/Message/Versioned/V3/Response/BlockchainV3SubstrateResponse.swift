//
//  BlockchainV3SubstrateResponse.swift
//  
//
//  Created by Julia Samol on 11.01.22.
//

import Foundation
import BeaconCore

public enum BlockchainV3SubstrateResponse: BlockchainV3SubstrateResponseProtocol {
    public typealias BlockchainType = Substrate
    
    case transfer(TransferV3SubstrateResponse)
    case signPayload(SignPayloadV3SubstrateResponse)
    
    // MARK: BeaconMessage Compatibility
    
    public init(from blockchainResponse: Substrate.Response.Blockchain) throws {
        switch blockchainResponse {
        case let .transfer(content):
            self = .transfer(TransferV3SubstrateResponse(from: content))
        case let .signPayload(content):
            self = .signPayload(SignPayloadV3SubstrateResponse(from: content))
        }
    }
    
    public func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Connection.ID,
        destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<Substrate>, Error>) -> ()
    ) {
        switch self {
        case let .transfer(content):
            content.toBeaconMessage(
                id: id,
                version: version,
                senderID: senderID,
                origin: origin,
                destination: destination,
                completion: completion
            )
        case let .signPayload(content):
            content.toBeaconMessage(
                id: id,
                version: version,
                senderID: senderID,
                origin: origin,
                destination: destination,
                completion: completion
            )
        }
    }
    
    // MARK: Attributes
    
    public var type: String {
        switch self {
        case let .transfer(content):
            return content.type
        case let .signPayload(content):
            return content.type
        }
    }
    
    // MARK: Codable
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case TransferV3SubstrateResponse.type:
            self = .transfer(try TransferV3SubstrateResponse(from: decoder))
        case SignPayloadV3SubstrateResponse.type:
            self = .signPayload(try SignPayloadV3SubstrateResponse(from: decoder))
        default:
            throw Beacon.Error.unknownMessageType(type, version: "3")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .transfer(content):
            try content.encode(to: encoder)
        case let .signPayload(content):
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
