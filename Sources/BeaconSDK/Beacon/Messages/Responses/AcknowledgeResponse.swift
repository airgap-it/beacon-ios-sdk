//
//  AcknowledgeResponse.swift
//  BeaconSDK
//
//  Created by Julia Samol on 02.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Response {
    
    /// Body of the `Beacon.Response.acknowledge` message.
    public struct Acknowledge: ResponseProtocol, Equatable, Codable {
        
        /// The value that identifies the request to which the message is responding.
        public let id: String
        
        let version: String
        let requestOrigin: Beacon.Origin
        
        init(from request: Beacon.Request) {
            self.init(id: request.common.id, version: request.common.version, requestOrigin: request.common.origin)
        }
        
        init(id: String, version: String, requestOrigin: Beacon.Origin) {
            self.id = id
            self.version = version
            self.requestOrigin = requestOrigin
        }
    }
}
