//
//  Permission.swift
//
//
//  Created by Julia Samol on 24.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public protocol PermissionProtocol {
    var accountIdentifier: String { get }
    var address: String { get }
    var senderID: String { get }
    var appMetadata: Beacon.AppMetadata { get }
    var publicKey: String { get }
    var connectedAt: Int64 { get }
    var threshold: Beacon.Threshold? { get }
}

// MARK: Any

public struct AnyPermission: PermissionProtocol, Codable, Equatable {
    public let accountIdentifier: String
    public let address: String
    public let senderID: String
    public let appMetadata: Beacon.AppMetadata
    public let publicKey: String
    public let connectedAt: Int64
    public let threshold: Beacon.Threshold?
    
    public init(_ permission: PermissionProtocol) {
        self.accountIdentifier = permission.accountIdentifier
        self.address = permission.address
        self.senderID = permission.senderID
        self.appMetadata = permission.appMetadata
        self.publicKey = permission.publicKey
        self.connectedAt = permission.connectedAt
        self.threshold = permission.threshold
    }
    
    init(
        accountIdentifier: String,
        address: String,
        senderID: String,
        appMetadata: Beacon.AppMetadata,
        publicKey: String,
        connectedAt: Int64,
        threshold: Beacon.Threshold? = nil
    ) {
        self.accountIdentifier = accountIdentifier
        self.address = address
        self.senderID = senderID
        self.appMetadata = appMetadata
        self.publicKey = publicKey
        self.connectedAt = connectedAt
        self.threshold = threshold
    }
}
