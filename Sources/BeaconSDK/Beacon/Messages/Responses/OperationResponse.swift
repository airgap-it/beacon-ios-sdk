//
//  OperationResponse.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Response {
    
    /// Body of the `Beacon.Response.operation` message.
    public struct Operation: ResponseProtocol, Equatable, Codable {
        
        /// The value that identifies the request to which the message is responding.
        public let id: String
        
        /// The hash of the broadcast operations.
        public let transactionHash: String
        
        let version: String
        let requestOrigin: Beacon.Origin
        
        public init(from request: Beacon.Request.Operation, transactionHash: String) {
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
