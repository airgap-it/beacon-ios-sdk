//
//  PermissionRequest.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Request {
    
    /// Body of the `Beacon.Request.permission` message.
    public struct Permission: RequestProtocol, Equatable, Codable {
        
        /// The value that identifies this request.
        public let id: String
        
        /// The value that identifies the sender of this request.
        public let senderID: String
        
        /// The metadata describing the dApp asking for permissions.
        public let appMetadata: Beacon.AppMetadata
        
        /// The network to which the permissions apply.
        public let network: Beacon.Network
        
        /// The list of permissions asked to be granted.
        public let scopes: [Beacon.Permission.Scope]
        
        /// The origination data of this request.
        public let origin: Beacon.Origin
        
        let version: String
        
        init(
            id: String,
            senderID: String,
            appMetadata: Beacon.AppMetadata,
            network: Beacon.Network,
            scopes: [Beacon.Permission.Scope],
            origin: Beacon.Origin,
            version: String
        ) {
            self.id = id
            self.senderID = senderID
            self.appMetadata = appMetadata
            self.network = network
            self.scopes = scopes
            self.origin = origin
            self.version = version
        }
    }
}
