//
//  BroadcastV2Request.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Message.Versioned.V2 {
    
    struct BroadcastRequest: Codable {
        let type: `Type`
        let version: String
        let id: String
        let senderID: String
        let network: Beacon.Network
        let signedTransaction: String
        
        init(version: String, id: String, senderID: String, network: Beacon.Network, signedTransaction: String) {
            type = .broadcastRequest
            self.version = version
            self.id = id
            self.senderID = senderID
            self.network = network
            self.signedTransaction = signedTransaction
        }
        
        // MARK: BeaconMessage Compatibility
        
        init(from beaconMessage: Beacon.Request.Broadcast, version: String, senderID: String) {
            self.init(
                version: version,
                id: beaconMessage.id,
                senderID: senderID,
                network: beaconMessage.network,
                signedTransaction: beaconMessage.signedTransaction
            )
        }
        
        func toBeaconMessage(
            with origin: Beacon.Origin,
            using storage: StorageManager,
            completion: @escaping (Result<Beacon.Message, Error>) -> ()
        ) {
            storage.findAppMetadata(where: { $0.senderID == senderID }) { result in
                let message = result.map { appMetadata in
                    Beacon.Message.request(
                        Beacon.Request.broadcast(
                            Beacon.Request.Broadcast(
                                id: id,
                                senderID: senderID,
                                appMetadata: appMetadata,
                                network: network,
                                signedTransaction: signedTransaction,
                                origin: origin
                            )
                        )
                    )
                }
                
                completion(message)
            }
        }
        
        // MARK: Codable
        
        enum CodingKeys: String, CodingKey {
            case type
            case version
            case id
            case senderID = "senderId"
            case network
            case signedTransaction
        }
    }
}
