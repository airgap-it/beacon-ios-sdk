//
//  AcknowledgeV2Response.swift
//  BeaconSDK
//
//  Created by Julia Samol on 02.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Message.Versioned.V2 {
    
    struct AcknowledgeResponse: V2MessageProtocol, Equatable, Codable {
        let type: `Type`
        let version: String
        let id: String
        let senderID: String
        
        init(version: String, id: String, senderID: String) {
            type = .acknowledgeResponse
            self.version = version
            self.id = id
            self.senderID = senderID
        }
        
        init(from beaconMessage: Beacon.Response.Acknowledge, senderID: String) {
            self.init(version: beaconMessage.version, id: beaconMessage.id, senderID: senderID)
        }
        
        func toBeaconMessage(
            with origin: Beacon.Origin,
            using storageManager: StorageManager,
            completion: @escaping (Result<Beacon.Message, Error>) -> ()
        ) {
            let message = Beacon.Response.Acknowledge(id: id, version: version, requestOrigin: origin)
            completion(.success(.response(.acknowledge(message))))
        }
    }
}
