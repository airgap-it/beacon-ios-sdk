//
//  PermissionV2Response.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Message.Versioned.V2 {
    
    struct PermissionResponse: Codable {
        let type: `Type`
        let version: String
        let id: String
        let senderID: String
        let publicKey: String
        let network: Beacon.Network
        let scopes: [Beacon.PermissionScope]
        let threshold: Beacon.Threshold?
        
        public init(
            version: String,
            id: String,
            senderID: String,
            publicKey: String,
            network: Beacon.Network,
            scopes: [Beacon.PermissionScope],
            threshold: Beacon.Threshold?
        ) {
            type = .permissionResponse
            self.version = version
            self.id = id
            self.senderID = senderID
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
                senderID: senderID,
                publicKey: beaconMessage.publicKey,
                network: beaconMessage.network,
                scopes: beaconMessage.scopes,
                threshold: beaconMessage.threshold
            )
        }
        
        func toBeaconMessage(
            with origin: Beacon.Origin,
            using storage: ExtendedStorage,
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
            case senderID = "senderId"
            case publicKey
            case network
            case scopes
            case threshold
        }
    }
}
