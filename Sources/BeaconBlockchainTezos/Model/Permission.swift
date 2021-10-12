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
        public let accountIdentifier: String
        
        /// The address of the account derived from its public key.
        public let address: String
        
        /// The network to which the permissions apply.
        public let network: Network
        
        /// The list of granted permission types.
        public let scopes: [Permission.Scope]
        
        /// The value that identifies the sender to whom the permissions were granted.
        public let senderID: String
        
        /// The metadata describing the dApp to which the permissions were granted.
        public let appMetadata: Beacon.AppMetadata
        
        /// The public key of the account.
        public let publicKey: String
        
        /// The timestamp at which the permissions were granted.
        public let connectedAt: Int64
        
        /// An optional threshold configuration.
        public let threshold: Beacon.Threshold?
        
        public init(
            accountIdentifier: String,
            address: String,
            network: Network,
            scopes: [Permission.Scope],
            senderID: String,
            appMetadata: Beacon.AppMetadata,
            publicKey: String,
            connectedAt: Int64,
            threshold: Beacon.Threshold? = nil
        ) {
            self.accountIdentifier = accountIdentifier
            self.address = address
            self.network = network
            self.scopes = scopes
            self.senderID = senderID
            self.appMetadata = appMetadata
            self.publicKey = publicKey
            self.connectedAt = connectedAt
            self.threshold = threshold
        }
        
        // MARK: Scope
        
        /// Types of permissions supported in Beacon.
        public enum Scope: String, Codable, Equatable {
            case sign
            case operationRequest = "operation_request"
            case threshold
        }
    }
}
