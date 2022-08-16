//
//  BeaconRequest.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

/// Types of requests used in the Beacon connection.
public enum BeaconRequest<B: Blockchain>: BeaconRequestProtocol, Equatable {
    
    ///
    /// Message requesting the granting of the specified permissions.
    ///
    /// - permission: The content of the message, specific to a blockchain.
    ///
    case permission(_ permission: B.Request.Permission)
    
    ///
    /// Blockchain specific request.
    ///
    /// - blockchain: The content of the message.
    ///
    case blockchain(_ blockchain: B.Request.Blockchain)
    
    // MARK: Attributes
    
    public var id: String { common.id }
    public var version: String { common.version }
    public var senderID: String { common.senderID }
    public var origin: Beacon.Connection.ID { common.origin }
    public var destination: Beacon.Connection.ID { common.destination }
    
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
    var senderID: String { get }
    var origin: Beacon.Connection.ID { get }
}

public protocol PermissionBeaconRequestProtocol: BeaconRequestProtocol {
    associatedtype AppMetadata: AppMetadataProtocol
    
    var appMetadata: AppMetadata { get }
}

public protocol BlockchainBeaconRequestProtocol: BeaconRequestProtocol {
    var accountID: String? { get }
}
