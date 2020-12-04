//
//  SignPayloadResponse.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Response {
    
    /// Body of the `Beacon.Response.signPayload` message.
    public struct SignPayload: ResponseProtocol, Equatable, Codable {
        
        /// The value that identifies the request to which the message is responding.
        public let id: String
        
        /// The signature type.
        public let signingType: Beacon.SigningType
        
        /// The payload signature.
        public let signature: String
        
        let version: String
        let requestOrigin: Beacon.Origin
        
        public init(from request: Beacon.Request.SignPayload, signature: String) {
            self.init(
                id: request.id,
                signingType: request.signingType,
                signature: signature,
                version: request.version,
                requestOrigin: request.origin
            )
        }
        
        init(id: String, signingType: Beacon.SigningType, signature: String, version: String, requestOrigin: Beacon.Origin) {
            self.id = id
            self.signingType = signingType
            self.signature = signature
            self.version = version
            self.requestOrigin = requestOrigin
        }
    }
}
