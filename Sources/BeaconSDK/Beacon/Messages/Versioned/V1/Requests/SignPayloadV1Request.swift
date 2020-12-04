//
//  SignPayloadV1Request.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Message.Versioned.V1 {
    
    struct SignPayloadRequest: V1MessageProtocol, Equatable, Codable {
        let type: `Type`
        let version: String
        let id: String
        let beaconID: String
        let payload: String
        let sourceAddress: String
        
        init(version: String, id: String, beaconID: String, payload: String, sourceAddress: String) {
            type = .signPayloadRequest
            self.version = version
            self.id = id
            self.beaconID = beaconID
            self.payload = payload
            self.sourceAddress = sourceAddress
        }
        
        // MARK: BeaconMessage Compatibility
        
        init(from beaconMessage: Beacon.Request.SignPayload, senderID: String) {
            self.init(
                version: beaconMessage.version,
                id: beaconMessage.id,
                beaconID: senderID,
                payload: beaconMessage.payload,
                sourceAddress: beaconMessage.sourceAddress
            )
        }
        
        func toBeaconMessage(
            with origin: Beacon.Origin,
            using storageManager: StorageManager,
            completion: @escaping (Result<Beacon.Message, Error>) -> ()
        ) {
            storageManager.findAppMetadata(where: { $0.senderID == beaconID }) { result in
                let message: Result<Beacon.Message, Error> = result.map { appMetadata in
                    .request(
                        .signPayload(
                            .init(
                                id: id,
                                senderID: beaconID,
                                appMetadata: appMetadata,
                                signingType: .raw,
                                payload: payload,
                                sourceAddress: sourceAddress,
                                origin: origin,
                                version: version
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
            case beaconID = "beaconId"
            case payload
            case sourceAddress
        }
    }
}
