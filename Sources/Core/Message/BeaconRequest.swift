//
//  BeaconRequest.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

/// Types of requests used in the Beacon connection.
public enum BeaconRequest<T: Blockchain>: BeaconRequestProtocol, Equatable {
    
    ///
    /// Message requesting the granting of the specified permissions.
    ///
    /// - permission: The content of the message, specific to a blockchain.
    ///
    case permission(_ permission: T.Request.Permission)
    
    ///
    /// Blockchain specific request.
    ///
    /// - blockchain: The content of the message.
    ///
    case blockchain(_ blockchain: T.Request.Blockchain)
    
    // MARK: Attributes
    
    public var id: String { common.id }
    public var version: String { common.version }
    public var blockchainIdentifier: String { common.blockchainIdentifier}
    public var senderID: String { common.senderID }
    public var origin: Beacon.Origin { common.origin }
    
    private var common: BeaconRequestProtocol {
        switch self {
        case let .permission(content):
            return content
        case let .blockchain(content):
            return content
        }
    }
}

// MARK: Protocol

public protocol BeaconRequestProtocol: BeaconMessageProtocol {
    var blockchainIdentifier: String { get }
    var senderID: String { get }
    var origin: Beacon.Origin { get }
}

public protocol PermissionBeaconRequestProtocol: BeaconRequestProtocol {
    associatedtype AppMetadata: AppMetadataProtocol & Codable & Equatable
    
    var appMetadata: AppMetadata { get }
}

public protocol BlockchainBeaconRequestProtocol: BeaconRequestProtocol {
    var accountID: String? { get }
}
