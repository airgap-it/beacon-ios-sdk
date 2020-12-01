//
//  PermissionV1Response.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Message.Versioned.V1 {
    
    struct PermissionResponse: V1MessageProtocol, Codable {
        let type: `Type`
        let version: String
        let id: String
        let beaconID: String
        let publicKey: String
        let network: Beacon.Network
        let scopes: [Beacon.PermissionScope]
        let threshold: Beacon.Threshold?
        
        public init(
            version: String,
            id: String,
            beaconID: String,
            publicKey: String,
            network: Beacon.Network,
            scopes: [Beacon.PermissionScope],
            threshold: Beacon.Threshold?
        ) {
            type = .permissionResponse
            self.version = version
            self.id = id
            self.beaconID = beaconID
            self.publicKey = publicKey
            self.network = network
            self.scopes = scopes
            self.threshold = threshold
        }
        
        // MARK: BeaconMessage Compatibility
        
        init(from beaconMessage: Beacon.Response.Permission, version: String, senderID: String) {
            self.init(
                version: version,
                id: beaconMessage.id,
                beaconID: senderID,
                publicKey: beaconMessage.publicKey,
                network: beaconMessage.network,
                scopes: beaconMessage.scopes,
                threshold: beaconMessage.threshold
            )
        }
        
        func comesFrom(_ appMetadata: Beacon.AppMetadata) -> Bool {
            appMetadata.senderID == beaconID
        }
        
        func toBeaconMessage(
            with origin: Beacon.Origin,
            using storage: StorageManager,
            completion: @escaping (Result<Beacon.Message, Error>) -> ()
        ) {
            let message = Beacon.Message.response(
                Beacon.Response.permission(
                    Beacon.Response.Permission.init(
                        id: id,
                        publicKey: publicKey,
                        network: network,
                        scopes: scopes,
                        threshold: threshold
                    )
                )
            )
            
            completion(.success(message))
        }
        
        // MARK: Codable
        
        enum CodingKeys: String, CodingKey {
            case type
            case version
            case id
            case beaconID = "beaconId"
            case publicKey
            case network
            case scopes
            case threshold
        }
    }
}
