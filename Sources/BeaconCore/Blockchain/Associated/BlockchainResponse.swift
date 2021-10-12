//
//  BlockchainResponse.swift
//  
//
//  Created by Julia Samol on 01.10.21.
//

import Foundation

public protocol BlockchainResponse {
    associatedtype Permission: PermissionBeaconResponseProtocol & Equatable
    associatedtype Blockchain: BlockchainBeaconResponseProtocol & Equatable
}

// MARK: Any

public struct AnyBlockchainResponse: BlockchainResponse {
    public typealias Permission = AnyPermissionBeaconResponse
    public typealias Blockchain = AnyBlockchainBeaconResponse
}

public class AnyBeaconResponse: BeaconResponseProtocol, Equatable {
    public let id: String
    public let version: String
    public let requestOrigin: Beacon.Origin
    
    init(id: String, version: String, requestOrigin: Beacon.Origin) {
        self.id = id
        self.version = version
        self.requestOrigin = requestOrigin
    }
    
    init(_ message: BeaconResponseProtocol) {
        self.id = message.id
        self.version = message.version
        self.requestOrigin = message.requestOrigin
    }
    
    // MARK: Equatable
    
    public static func ==(lhs: AnyBeaconResponse, rhs: AnyBeaconResponse) -> Bool {
        lhs.id == rhs.id && lhs.version == rhs.version && lhs.requestOrigin == rhs.requestOrigin
    }
}

public class AnyPermissionBeaconResponse: AnyBeaconResponse, PermissionBeaconResponseProtocol {
    public let blockchainIdentifier: String
    public let publicKey: String
    public let threshold: Beacon.Threshold?
    
    init(
        id: String,
        version: String,
        requestOrigin: Beacon.Origin,
        blockchainIdentifier: String,
        publicKey: String,
        threshold: Beacon.Threshold? = nil
    ) {
        self.blockchainIdentifier = blockchainIdentifier
        self.publicKey = publicKey
        self.threshold = threshold
        super.init(id: id, version: version, requestOrigin: requestOrigin)
    }
    
    init(_ message: PermissionBeaconResponseProtocol) {
        self.blockchainIdentifier = message.blockchainIdentifier
        self.publicKey = message.publicKey
        self.threshold = message.threshold
        super.init(message)
    }
    
    public static func ==(lhs: AnyPermissionBeaconResponse, rhs: AnyPermissionBeaconResponse) -> Bool {
        lhs.id == rhs.id && lhs.version == rhs.version && lhs.requestOrigin == rhs.requestOrigin && lhs.blockchainIdentifier == rhs.blockchainIdentifier && lhs.publicKey == rhs.publicKey && lhs.threshold == rhs.threshold
    }
}

public class AnyBlockchainBeaconResponse: AnyBeaconResponse, BlockchainBeaconResponseProtocol {
    public let blockchainIdentifier: String
    
    init(id: String, version: String, requestOrigin: Beacon.Origin, blockchainIdentifier: String) {
        self.blockchainIdentifier = blockchainIdentifier
        super.init(id: id, version: version, requestOrigin: requestOrigin)
    }
    
    init(_ message: BlockchainBeaconResponseProtocol) {
        self.blockchainIdentifier = message.blockchainIdentifier
        super.init(message)
    }
    
    public static func ==(lhs: AnyBlockchainBeaconResponse, rhs: AnyBlockchainBeaconResponse) -> Bool {
        lhs.id == rhs.id && lhs.version == rhs.version && lhs.requestOrigin == rhs.requestOrigin && lhs.blockchainIdentifier == rhs.blockchainIdentifier
    }
}
