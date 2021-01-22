//
//  BroadcastResponse.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Response {
    
    /// Body of the `Beacon.Response.broadcast` message.
    public struct Broadcast: ResponseProtocol, Equatable, Codable {
        
        /// The value that identifies the request to which the message is responding.
        public let id: String
        
        /// The hash of the broadcast transaction.
        public let transactionHash: String
        
        let version: String
        let requestOrigin: Beacon.Origin
        
        public init(from request: Beacon.Request.Broadcast, transactionHash: String) {
            self.init(id: request.id, transactionHash: transactionHash, version: request.version, requestOrigin: request.origin)
        }
        
        public init(id: String, transactionHash: String, version: String, requestOrigin: Beacon.Origin) {
            self.id = id
            self.transactionHash = transactionHash
            self.version = version
            self.requestOrigin = requestOrigin
        }
    }
}
