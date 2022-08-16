//
//  BlockchainV3BeaconResponseContent.swift
//  
//
//  Created by Julia Samol on 04.01.22.
//

import Foundation

public struct BlockchainV3BeaconResponseContent<Data: BlockchainV3BeaconResponseContentDataProtocol>: V3BeaconMessageContentProtocol {
    public let type: String
    public let blockchainIdentifier: String
    public let blockchainData: Data
    
    public init(blockchainData: Data) {
        self.type = BlockchainV3BeaconResponseContent.type
        self.blockchainIdentifier = Data.BlockchainType.identifier
        self.blockchainData = blockchainData
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from beaconMessage: BeaconMessage<Data.BlockchainType>) throws {
        switch beaconMessage {
        case let .response(response):
            switch response {
            case let .blockchain(content):
                try self.init(from: content)
            default:
                throw Beacon.Error.unknownBeaconMessage
            }
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from blockchainResponse: Data.BlockchainType.Response.Blockchain) throws {
        let blockchainData = try Data(from: blockchainResponse)
        self.init(blockchainData: blockchainData)
    }
    
    public func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Connection.ID,
        destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<Data.BlockchainType>, Swift.Error>) -> ()
    ) {
        blockchainData.toBeaconMessage(
            id: id,
            version: version,
            senderID: senderID,
            origin: origin,
            destination: destination,
            completion: completion
        )
    }
    
    // MARK: Codable
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let blockchainIdentifier = try container.decode(String.self, forKey: .blockchainIdentifier)
        guard blockchainIdentifier == Data.BlockchainType.identifier else {
            throw Beacon.Error.unexpectedBlockchainIdentifier(blockchainIdentifier)
        }
        let blockchainData = try Data(from: container.superDecoder(forKey: .blockchainData))
        self.init(blockchainData: blockchainData)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type, forKey: .type)
        try container.encode(blockchainIdentifier, forKey: .blockchainIdentifier)
        try blockchainData.encode(to: container.superEncoder(forKey: .blockchainData))
    }
    
    // MARK: Types
    
    enum CodingKeys: String, CodingKey {
        case type
        case blockchainIdentifier
        case blockchainData
    }
}

// MARK: Extensions

extension BlockchainV3BeaconResponseContent {
    static var type: String { "blockchain_response" }
}

// MARK: Protocol

public protocol BlockchainV3BeaconResponseContentDataProtocol: Codable, Equatable {
    associatedtype BlockchainType: Blockchain
    
    init(from blockchainResponse: BlockchainType.Response.Blockchain) throws
    func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Connection.ID,
        destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<BlockchainType>, Error>) -> ()
    )
}
