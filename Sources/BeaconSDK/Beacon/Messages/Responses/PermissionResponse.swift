//
//  PermissionResponse.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Response {
    
    /// Body of the `Beacon.Response.permission` message.
    public struct Permission: ResponseProtocol, Equatable, Codable {
        
        /// The value that identifies the request to which the message is responding.
        public let id: String
        
        /// The public key of the account that is granting the permissions.
        public let publicKey: String
        
        /// The network to which the permissions apply.
        public let network: Beacon.Network
        
        /// The list of granted permissions.
        public let scopes: [Beacon.PermissionScope]
        
        /// An optional threshold configuration.
        public let threshold: Beacon.Threshold?
        
        
        public init(
            id: String,
            publicKey: String,
            network: Beacon.Network,
            scopes: [Beacon.PermissionScope],
            threshold: Beacon.Threshold? = nil
        ) {
            self.id = id
            self.publicKey = publicKey
            self.network = network
            self.scopes = scopes
            self.threshold = threshold
        }
    }
}
