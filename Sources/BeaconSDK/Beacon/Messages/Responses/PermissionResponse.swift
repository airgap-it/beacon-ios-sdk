//
//  PermissionResponse.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Response {
    
    public struct Permission: ResponseProtocol, Equatable, Codable {
        public let id: String
        public let publicKey: String
        public let network: Beacon.Network
        public let scopes: [Beacon.PermissionScope]
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
