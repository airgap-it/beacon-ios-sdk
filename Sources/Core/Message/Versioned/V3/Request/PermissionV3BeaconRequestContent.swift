//
//  PermissionV3BeaconRequestContent.swift
//  
//
//  Created by Julia Samol on 04.01.22.
//

import Foundation

public struct PermissionV3BeaconRequestContent<Data: PermissionV3BeaconRequestContentDataProtocol>: V3BeaconMessageContentProtocol {
    public let type: String
    public let blockchainIdentifier: String
    public let blockchainData: Data
    
    public init(blockchainData: Data) {
        self.type = PermissionV3BeaconRequestContent.type
        self.blockchainIdentifier = Data.BlockchainType.identifier
        self.blockchainData = blockchainData
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from beaconMessage: BeaconMessage<Data.BlockchainType>) throws {
        switch beaconMessage {
        case let .request(request):
            switch request {
            case let .permission(content):
                try self.init(from: content)
            default:
                throw Beacon.Error.unknownBeaconMessage
            }
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from permissionRequest: Data.BlockchainType.Request.Permission) throws {
        let blockchainData = try Data(from: permissionRequest)
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

extension PermissionV3BeaconRequestContent {
    static var type: String { "permission_request" }
}

// MARK: Protocol

public protocol PermissionV3BeaconRequestContentDataProtocol: Codable, Equatable {
    associatedtype BlockchainType: Blockchain
    
    init(from permissionRequest: BlockchainType.Request.Permission) throws
    func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Connection.ID,
        destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<BlockchainType>, Error>) -> ()
    )
}
