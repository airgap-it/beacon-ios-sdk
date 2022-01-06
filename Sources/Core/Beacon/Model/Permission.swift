//
//  Permission.swift
//
//
//  Created by Julia Samol on 24.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

/// Granted permissions data.
public protocol PermissionProtocol {
    associatedtype AppMetadata: AppMetadataProtocol
    
    /// The value that identifies the account which granted the permissions.
    var accountIdentifier: String { get }
    
    /// The address of the account derived from its public key.
    var address: String { get }
    
    /// The value that identifies the sender to whom the permissions were granted.
    var senderID: String { get }
    
    /// The metadata describing the dApp to which the permissions were granted.
    var appMetadata: AppMetadata { get }
    
    /// The public key of the account.
    var publicKey: String { get }
    
    /// The timestamp at which the permissions were granted.
    var connectedAt: Int64 { get }
}

// MARK: Any

public struct AnyPermission: PermissionProtocol, Codable, Equatable {
    public typealias AppMetadata = AnyAppMetadata
    
    public let accountIdentifier: String
    public let address: String
    public let senderID: String
    public let appMetadata: AppMetadata
    public let publicKey: String
    public let connectedAt: Int64
    
    public init<T: PermissionProtocol>(_ permission: T) {
        self.accountIdentifier = permission.accountIdentifier
        self.address = permission.address
        self.senderID = permission.senderID
        self.appMetadata = AnyAppMetadata(permission.appMetadata)
        self.publicKey = permission.publicKey
        self.connectedAt = permission.connectedAt
    }
    
    init(
        accountIdentifier: String,
        address: String,
        senderID: String,
        appMetadata: AppMetadata,
        publicKey: String,
        connectedAt: Int64
    ) {
        self.accountIdentifier = accountIdentifier
        self.address = address
        self.senderID = senderID
        self.appMetadata = appMetadata
        self.publicKey = publicKey
        self.connectedAt = connectedAt
    }
}
