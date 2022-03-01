//
//  AnyLegacyPermission.swift
//  
//
//  Created by Julia Samol on 01.03.22.
//

import Foundation
import BeaconCore

public struct AnyLegacyPermission: LegacyPermissionProtocol {
    public static var fromVersion: String = ""
    public static var blockchainIdentifier: String? = nil
    
    public let accountID: String
    public let senderID: String
    public let connectedAt: Int64
    
    public init(accountID: String, senderID: String, connectedAt: Int64) {
        self.accountID = accountID
        self.senderID = senderID
        self.connectedAt = connectedAt
    }
    
    public init<T: LegacyPermissionProtocol>(_ legacyPermission: T) {
        self.init(accountID: legacyPermission.accountID, senderID: legacyPermission.senderID, connectedAt: legacyPermission.connectedAt)
    }
}
