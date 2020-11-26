//
//  PermissionInfo.swift
//  BeaconSDK
//
//  Created by Julia Samol on 24.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    public struct PermissionInfo: Codable, Equatable {
        public let accountIdentifier: String
        public let address: String
        public let network: Network
        public let scopes: [PermissionScope]
        public let senderID: String
        public let appMetadata: AppMetadata
        public let publicKey: String
        public let connectedAt: Int64
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
