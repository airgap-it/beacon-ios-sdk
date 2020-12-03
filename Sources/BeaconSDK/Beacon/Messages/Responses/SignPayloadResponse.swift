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
        
        /// The payload signature.
        public let signature: String
    }
}
