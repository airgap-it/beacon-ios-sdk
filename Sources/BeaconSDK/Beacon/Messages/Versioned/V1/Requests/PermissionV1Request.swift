//
//  PermissionV1Request.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Message.Versioned.V1 {
    
    struct PermissionRequest: V1MessageProtocol, Equatable, Codable {
        let type: `Type`
        let version: String
        let id: String
        let beaconID: String
        let appMetadata: AppMetadata
        let network: Beacon.Network
        let scopes: [Beacon.Permission.Scope]
        
        init(
            version: String,
            id: String,
            beaconID: String,
            appMetadata: AppMetadata,
            network: Beacon.Network,
            scopes: [Beacon.Permission.Scope]
        ) {
            type = .permissionRequest
            self.version = version
            self.id = id
            self.beaconID = beaconID
            self.appMetadata = appMetadata
            self.network = network
            self.scopes = scopes
        }
        
        // MARK: BeaconMessage Compatibility
        
        init(from beaconMessage: Beacon.Request.Permission, senderID: String) {
            self.init(
                version: beaconMessage.version,
                id: beaconMessage.id,
                beaconID: senderID,
                appMetadata: AppMetadata(from: beaconMessage.appMetadata),
                network: beaconMessage.network,
                scopes: beaconMessage.scopes
            )
        }
        
        func toBeaconMessage(
            with origin: Beacon.Origin,
            using storageManager: StorageManager,
            completion: @escaping (Result<Beacon.Message, Error>) -> ()
        ) {
            let message = Beacon.Request.Permission(
                id: id,
                senderID: beaconID,
                appMetadata: appMetadata.toAppMetadata(),
                network: network,
                scopes: scopes,
                origin: origin,
                version: version
            )
            
            completion(.success(.request(.permission(message))))
        }
        
        // MARK: Codable
        
        enum CodingKeys: String, CodingKey {
            case type
            case version
            case id
            case beaconID = "beaconId"
            case appMetadata
            case network
            case scopes
        }
    }
    
    // MARK: Types
    
    struct AppMetadata: Equatable, Codable {
        public let beaconID: String
        public let name: String
        public let icon: String?
        
        init(from appMetadata: Beacon.AppMetadata) {
            self.beaconID = appMetadata.senderID
            self.name = appMetadata.name
            self.icon = appMetadata.icon
        }
        
        func toAppMetadata() -> Beacon.AppMetadata {
            Beacon.AppMetadata(senderID: beaconID, name: name, icon: icon)
        }
        
        enum CodingKeys: String, CodingKey {
            case beaconID = "beaconId"
            case name
            case icon
        }
    }
}
