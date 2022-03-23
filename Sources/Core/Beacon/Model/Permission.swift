//
//  Permission.swift
//
//
//  Created by Julia Samol on 24.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

/// Granted permissions data.
public protocol PermissionProtocol: Equatable, Codable {
    
    static var blockchainIdentifier: String? { get }
    
    /// The value that identifies the account which granted the permissions.
    var accountID: String { get }
    
    /// The value that identifies the sender to whom the permissions were granted.
    var senderID: String { get }
    
    /// The timestamp at which the permissions were granted.
    var connectedAt: Int64 { get }
}

// MARK: Any

public struct AnyPermission: PermissionProtocol, Codable, Equatable {
    public static let blockchainIdentifier: String? = nil
    
    public let accountID: String
    public let senderID: String
    public let connectedAt: Int64
    
    public init<T: PermissionProtocol>(_ permission: T) {
        self.accountID = permission.accountID
        self.senderID = permission.senderID
        self.connectedAt = permission.connectedAt
    }
    
    init(
        accountID: String,
        senderID: String,
        connectedAt: Int64
    ) {
        self.accountID = accountID
        self.senderID = senderID
        self.connectedAt = connectedAt
    }
}
