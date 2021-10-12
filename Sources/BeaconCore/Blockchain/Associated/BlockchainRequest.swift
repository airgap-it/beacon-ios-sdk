//
//  BlockchainRequest.swift
//  
//
//  Created by Julia Samol on 01.10.21.
//

import Foundation

public protocol BlockchainRequest {
    associatedtype Permission: PermissionBeaconRequestProtocol & Equatable
    associatedtype Blockchain: BlockchainBeaconRequestProtocol & Equatable
}

// MARK: Any

public class AnyBeaconRequest: BeaconRequestProtocol, Equatable {
    public let id: String
    public let version: String
    public let blockchainIdentifier: String
    public let senderID: String
    public let origin: Beacon.Origin
    
    init(id: String, version: String, blockchainIdentifier: String, senderID: String, origin: Beacon.Origin) {
        self.id = id
        self.version = version
        self.blockchainIdentifier = blockchainIdentifier
        self.senderID = senderID
        self.origin = origin
    }
    
    init(_ message: BeaconRequestProtocol) {
        self.id = message.id
        self.version = message.version
        self.blockchainIdentifier = message.blockchainIdentifier
        self.senderID = message.senderID
        self.origin = message.origin
    }
    
    public static func == (lhs: AnyBeaconRequest, rhs: AnyBeaconRequest) -> Bool {
        lhs.id == rhs.id && lhs.version == rhs.version && lhs.blockchainIdentifier == rhs.blockchainIdentifier && lhs.senderID == rhs.senderID && lhs.origin == rhs.origin
    }
}

public struct AnyBlockchainRequest: BlockchainRequest {
    public typealias Permission = AnyPermissionBeaconRequest
    public typealias Blockchain = AnyBlockchainBeaconRequest
}

public class AnyPermissionBeaconRequest: AnyBeaconRequest, PermissionBeaconRequestProtocol {
    public let appMetadata: Beacon.AppMetadata
    
    init(
        id: String,
        version: String,
        blockchainIdentifier: String,
        senderID: String,
        origin: Beacon.Origin,
        appMetadata: Beacon.AppMetadata
    ) {
        self.appMetadata = appMetadata
        super.init(
            id: id,
            version: version,
            blockchainIdentifier: blockchainIdentifier,
            senderID: senderID,
            origin: origin
        )
    }
    
    init(_ message: PermissionBeaconRequestProtocol) {
        self.appMetadata = message.appMetadata
        super.init(message)
    }
    
    public static func == (lhs: AnyPermissionBeaconRequest, rhs: AnyPermissionBeaconRequest) -> Bool {
        lhs.id == rhs.id && lhs.version == rhs.version && lhs.blockchainIdentifier == rhs.blockchainIdentifier && lhs.senderID == rhs.senderID && lhs.appMetadata == rhs.appMetadata && lhs.origin == rhs.origin
    }
}

public class AnyBlockchainBeaconRequest: AnyBeaconRequest, BlockchainBeaconRequestProtocol {}
