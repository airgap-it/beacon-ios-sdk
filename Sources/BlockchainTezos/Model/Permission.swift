//
//  Permission.swift
//  
//
//  Created by Julia Samol on 30.09.21.
//

import Foundation
import BeaconCore

extension Tezos {
    
    /// Granted Tezos permissions data.
    public struct Permission: PermissionProtocol, Codable, Equatable {
        
        /// The value that identifies the account which granted the permissions.
        public let accountID: String
        
        /// The value that identifies the sender to whom the permissions were granted.
        public let senderID: String
        
        /// The timestamp at which the permissions were granted.
        public let connectedAt: Int64
        
        /// The address of the account derived from its public key.
        public let address: String
        
        /// The public key of the account.
        public let publicKey: String
        
        /// The network to which the permissions apply.
        public let network: Network
        
        /// The metadata describing the dApp to which the permissions were granted.
        public let appMetadata: AppMetadata
        
        /// The list of granted permission types.
        public let scopes: [Permission.Scope]
        
        public init(
            accountIdentifier: String,
            senderID: String,
            connectedAt: Int64,
            address: String,
            publicKey: String,
            network: Network,
            appMetadata: AppMetadata,
            scopes: [Permission.Scope]
        ) {
            self.accountID = accountIdentifier
            self.senderID = senderID
            self.connectedAt = connectedAt
            self.address = address
            self.publicKey = publicKey
            self.network = network
            self.appMetadata = appMetadata
            self.scopes = scopes
        }
        
        // MARK: Scope
        
        /// Types of permissions supported in Beacon.
        public enum Scope: String, Codable, Equatable {
            case sign
            case operationRequest = "operation_request"
        }
        
        // MARK: Types
        
        enum CodingKeys: String, CodingKey {
            case accountID = "accountIdentifier"
            case address
            case network
            case scopes
            case senderID
            case appMetadata
            case publicKey
            case connectedAt
        }
    }
}
