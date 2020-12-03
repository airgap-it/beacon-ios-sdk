//
//  PermissionInfo.swift
//  BeaconSDK
//
//  Created by Julia Samol on 24.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    /// Granted permissions data.
    public struct PermissionInfo: Codable, Equatable {
        
        /// The value that identifies the account which granted the permissions.
        public let accountIdentifier: String
        
        /// The address of the account derived from its public key.
        public let address: String
        
        /// The network to which the permissions apply.
        public let network: Network
        
        /// The list of granted permission types.
        public let scopes: [PermissionScope]
        
        /// The value that identifies the sender to whom the permissions were granted.
        public let senderID: String
        
        /// The metadata describing the dApp to which the permissions were granted.
        public let appMetadata: AppMetadata
        
        /// The public key of the account.
        public let publicKey: String
        
        /// The timestamp at which the permissions were granted.
        public let connectedAt: Int64
        
        /// An optional threshold configuration.
        public let threshold: Threshold?
        
        public init(
            accountIdentifier: String,
            address: String,
            network: Network,
            scopes: [PermissionScope],
            senderID: String,
            appMetadata: AppMetadata,
            publicKey: String,
            connectedAt: Int64,
            threshold: Threshold? = nil
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
    }
}
