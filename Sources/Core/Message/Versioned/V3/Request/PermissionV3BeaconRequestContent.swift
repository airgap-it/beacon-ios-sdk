//
//  PermissionV3BeaconRequestContent.swift
//  
//
//  Created by Julia Samol on 04.01.22.
//

import Foundation

public struct PermissionV3BeaconRequestContent: V3BeaconMessageContentProtocol, Equatable, Codable {
    public let type: String
    public let blockchainIdentifier: String
    public let blockchainData: PermissionV3BeaconRequestContentDataProtocol & Codable
    
    public init(blockchainIdentifier: String, blockchainData: PermissionV3BeaconRequestContentDataProtocol & Codable) {
        self.type = PermissionV3BeaconRequestContent.type
        self.blockchainIdentifier = blockchainIdentifier
        self.blockchainData = blockchainData
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>) throws {
        switch beaconMessage {
        case let .request(request):
            switch request {
            case let .permission(content):
                try self.init(from: content, ofType: T.self)
            default:
                throw Beacon.Error.unknownBeaconMessage
            }
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init<T: Blockchain>(from permissionRequest: PermissionBeaconRequestProtocol, ofType type: T.Type) throws {
        let blockchainData = try type.VersionedMessage.V3.PermissionRequestContentData(from: permissionRequest)
        self.init(blockchainIdentifier: permissionRequest.blockchainIdentifier, blockchainData: blockchainData)
    }
    
    public func toBeaconMessage<T: Blockchain>(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        using storageManager: StorageManager,
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    ) {
        blockchainData.toBeaconMessage(
            id: id,
            version: version,
            senderID: senderID,
            origin: origin,
            blockchainIdentifier: blockchainIdentifier,
            using: storageManager,
            completion: completion
        )
    }
    
    // MARK: Equatable
    
    public static func == (lhs: PermissionV3BeaconRequestContent, rhs: PermissionV3BeaconRequestContent) -> Bool {
        lhs.type == rhs.type && lhs.blockchainIdentifier == rhs.blockchainIdentifier && lhs.blockchainData.equals(rhs.blockchainData)
    }
    
    // MARK: Codable
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let blockchainIdentifier = try container.decode(String.self, forKey: .blockchainIdentifier)
    
        guard let blockchain = try blockchainRegistry().get(ofType: blockchainIdentifier) else {
            throw Beacon.Error.blockchainNotFound(blockchainIdentifier)
        }
        
        let blockchainData = try blockchain.decoder.v3.permissionRequestData(from: container.superDecoder(forKey: .blockchainData))
        
        self.init(blockchainIdentifier: blockchainIdentifier, blockchainData: blockchainData)
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

public protocol PermissionV3BeaconRequestContentDataProtocol {
    init(from permissionRequest: PermissionBeaconRequestProtocol) throws
    
    func toBeaconMessage<T: Blockchain>(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        blockchainIdentifier: String,
        using storageManager: StorageManager,
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    )
    
    func equals(_ other: PermissionV3BeaconRequestContentDataProtocol) -> Bool
}
