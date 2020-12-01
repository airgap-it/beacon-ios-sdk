//
//  ErrorV2Response.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Message.Versioned.V2 {
    
    struct ErrorResponse: V2MessageProtocol, Codable {
        let type: `Type`
        let version: String
        let id: String
        let senderID: String
        let errorType: Beacon.ErrorType
        
        init(version: String, id: String, senderID: String, errorType: Beacon.ErrorType) {
            type = .errorResponse
            self.version = version
            self.id = id
            self.senderID = senderID
            self.errorType = errorType
        }
        
        // MARK: BeaconMessage Compatibility
        
        init(from beaconMessage: Beacon.Response.Error, version: String, senderID: String) {
            self.init(version: version, id: beaconMessage.id, senderID: senderID, errorType: beaconMessage.errorType)
        }
        
        func comesFrom(_ appMetadata: Beacon.AppMetadata) -> Bool {
            appMetadata.senderID == senderID
        }
        
        func toBeaconMessage(
            with origin: Beacon.Origin,
            using storage: StorageManager,
            completion: @escaping (Result<Beacon.Message, Error>) -> ()
        ) {
            let message = Beacon.Message.response(
                Beacon.Response.error(
                    Beacon.Response.Error(id: id, errorType: errorType)
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
            case errorType
        }
    }
}
