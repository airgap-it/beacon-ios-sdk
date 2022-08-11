//
//  BlockchainV3BeaconRequestContent.swift
//  
//
//  Created by Julia Samol on 04.01.22.
//

import Foundation

public struct BlockchainV3BeaconRequestContent<Data: BlockchainV3BeaconRequestContentDataProtocol>: V3BeaconMessageContentProtocol {
    public let type: String
    public let blockchainIdentifier: String
    public let accountID: String
    public let blockchainData: Data
    
    public init(accountID: String, blockchainData: Data) {
        self.type = BlockchainV3BeaconRequestContent.type
        self.blockchainIdentifier = Data.BlockchainType.identifier
        self.accountID = accountID
        self.blockchainData = blockchainData
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from beaconMessage: BeaconMessage<Data.BlockchainType>) throws {
        switch beaconMessage {
        case let .request(request):
            switch request {
            case let .blockchain(content):
                try self.init(from: content)
            default:
                throw Beacon.Error.unknownBeaconMessage
            }
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from blockchainRequest: Data.BlockchainType.Request.Blockchain) throws {
        let blockchainData = try Data(from: blockchainRequest)
        guard let accountID = blockchainRequest.accountID else {
            throw Error.missingAccountID
        }
        
        self.init(accountID: accountID, blockchainData: blockchainData)
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
            accountID: accountID,
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
        let accountID = try container.decode(String.self, forKey: .accountID)
        let blockchainData = try Data(from: container.superDecoder(forKey: .blockchainData))
        self.init(accountID: accountID, blockchainData: blockchainData)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type, forKey: .type)
        try container.encode(blockchainIdentifier, forKey: .blockchainIdentifier)
        try container.encode(accountID, forKey: .accountID)
        try blockchainData.encode(to: container.superEncoder(forKey: .blockchainData))
    }
    
    // MARK: Types
    
    enum CodingKeys: String, CodingKey {
        case type
        case blockchainIdentifier
        case accountID = "accountId"
        case blockchainData
    }
    
    enum Error: Swift.Error {
        case missingAccountID
    }
}

// MARK: Extensions

extension BlockchainV3BeaconRequestContent {
    static var type: String { "blockchain_request" }
}

// MARK: Protocol

public protocol BlockchainV3BeaconRequestContentDataProtocol: Codable, Equatable {
    associatedtype BlockchainType: Blockchain
    
    init(from blockchainRequest: BlockchainType.Request.Blockchain) throws
    func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Connection.ID,
        destination: Beacon.Connection.ID,
        accountID: String,
        completion: @escaping (Result<BeaconMessage<BlockchainType>, Error>) -> ()
    )
}
