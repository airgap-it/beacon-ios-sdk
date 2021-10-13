//
//  BeaconResponse.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
/// Types of responses used in the Beacon connection.
public enum BeaconResponse<T: Blockchain>: BeaconResponseProtocol, Equatable {
    
    ///
    /// Message responding to `BeaconRequest.permission`
    ///
    /// - permission: The content of the message, specific to a blockchain.
    ///
    case permission(_ permission: T.Response.Permission)
    
    ///
    /// Message responding to `BeaconRequest.blockchain`
    ///
    /// - blockchain: The content of the message.
    ///
    case blockchain(_ blockchain: T.Response.Blockchain)
    
    ///
    /// Message responding to every `BeaconRequest`,
    /// sent to confirm receiving of the request.
    ///
    /// Used internally.
    ///
    /// - acknowledge: The body of the message.
    ///
    case acknowledge(_ acknowledge: AcknowledgeBeaconResponse)
    
    ///
    /// Message responding to every `BeaconRequest`
    /// and informing that the request could not be completed due to an error.
    ///
    /// - error: The body of the message.
    ///
    case error(_ error: ErrorBeaconResponse<T>)
    
    // MARK: Attributes
    
    public var id: String { common.id }
    public var version: String { common.version }
    
    public var requestOrigin: Beacon.Origin { common.requestOrigin }
    
    private var common: BeaconResponseProtocol {
        switch self {
        case let .acknowledge(content):
            return content
        case let .error(content):
            return content
        case let .permission(content):
            return content
        case let .blockchain(content):
            return content
        }
    }
}

// MARK: Protocol

public protocol BeaconResponseProtocol: BeaconMessageProtocol {
    var requestOrigin: Beacon.Origin { get }
}

public protocol PermissionBeaconResponseProtocol: BeaconResponseProtocol {
    var blockchainIdentifier: String { get }
    var publicKey: String { get }
    var threshold: Beacon.Threshold? { get }
}

public protocol BlockchainBeaconResponseProtocol: BeaconResponseProtocol {
    var blockchainIdentifier: String { get }
}
