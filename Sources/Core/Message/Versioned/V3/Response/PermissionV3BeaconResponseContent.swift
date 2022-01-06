//
//  PermissionV3BeaconResponseContent.swift
//  
//
//  Created by Julia Samol on 04.01.22.
//

import Foundation

public struct PermissionV3BeaconResponseContent: V3BeaconMessageContentProtocol, Equatable, Codable {
    public let type: String
    public let blockchainIdentifier: String
    public let accountID: String
    public let blockchainData: PermissionV3BeaconResponseContentDataProtocol & Codable
    
    public init(blockchainIdentifier: String, accountID: String, blockchainData: PermissionV3BeaconResponseContentDataProtocol & Codable) {
        self.type = PermissionV3BeaconResponseContent.type
        self.blockchainIdentifier = blockchainIdentifier
        self.accountID = accountID
        self.blockchainData = blockchainData
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>) throws {
        switch beaconMessage {
        case let .response(response):
            switch response {
            case let .permission(content):
                try self.init(from: content, ofType: T.self)
            default:
                throw Beacon.Error.unknownBeaconMessage
            }
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init<T: Blockchain>(from permissionResponse: T.Response.Permission, ofType type: T.Type) throws {
        let data = try type.VersionedMessage.V3.PermissionResponseContentData(from: permissionResponse, ofType: type)
        self.init(blockchainIdentifier: permissionResponse.blockchainIdentifier, accountID: permissionResponse.accountID, blockchainData: data)
    }
    
    public func toBeaconMessage<T: Blockchain>(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    ) {
        blockchainData.toBeaconMessage(
            id: id,
            version: version,
            senderID: senderID,
            origin: origin,
            blockchainIdentifier: blockchainIdentifier,
            accountID: accountID,
            completion: completion
        )
    }
    
    // MARK: Equatable
    
    public static func == (lhs: PermissionV3BeaconResponseContent, rhs: PermissionV3BeaconResponseContent) -> Bool {
        lhs.type == rhs.type && lhs.blockchainIdentifier == rhs.blockchainIdentifier && lhs.accountID == rhs.accountID && lhs.blockchainData.equals(rhs.blockchainData)
    }
    
    // MARK: Codable
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let blockchainIdentifier = try container.decode(String.self, forKey: .blockchainIdentifier)
        let accountID = try container.decode(String.self, forKey: .accountID)
        
        guard let blockchain = try blockchainRegistry().get(ofType: blockchainIdentifier) else {
            throw Beacon.Error.blockchainNotFound(blockchainIdentifier)
        }
        
        let blockchainData = try blockchain.decoder.v3.permissionResponseData(from: container.superDecoder(forKey: .blockchainData))
        
        self.init(blockchainIdentifier: blockchainIdentifier, accountID: accountID, blockchainData: blockchainData)
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
}

// MARK: Extensions

extension PermissionV3BeaconResponseContent {
    static var type: String { "permission_response" }
}

// MARK: Protocol

public protocol PermissionV3BeaconResponseContentDataProtocol {
    init<T: Blockchain>(from permissionResponse: T.Response.Permission, ofType type: T.Type) throws
    
    func toBeaconMessage<T: Blockchain>(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        blockchainIdentifier: String,
        accountID: String,
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    )
    
    func equals(_ other: PermissionV3BeaconResponseContentDataProtocol) -> Bool
}
