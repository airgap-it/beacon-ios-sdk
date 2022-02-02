//
//  Permission.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

extension Substrate {
    
    /// Granted Substrate permission data.
    public struct Permission: PermissionProtocol, Codable, Equatable {
        
        /// The value that identifies the account which granted the permissions.
        public var accountID: String
        
        /// The value that identifies the sender to whom the permissions were granted.
        public var senderID: String
        
        /// The timestamp at which the permissions were granted.
        public var connectedAt: Int64
        
        /// The metadata describing the dApp to which the permissions were granted.
        public let appMetadata: AppMetadata
        
        /// The list of granted permission types.
        public let scopes: [Scope]
        
        /// The account to which the permission apply.
        public let account: Account
        
        public init(accountID: String, senderID: String, connectedAt: Int64, appMetadata: AppMetadata, scopes: [Scope], account: Account) {
            self.accountID = accountID
            self.senderID = senderID
            self.connectedAt = connectedAt
            self.appMetadata = appMetadata
            self.scopes = scopes
            self.account = account
        }
     
        // MARK: Scope
        
        /// Types of Substrate permissions supported in Beacon.
        public enum Scope: String, Codable, Equatable {
            case transfer
            case signRaw = "sign_raw"
            case signString = "sign_string"
        }
    }
}
