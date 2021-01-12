//
//  ErrorResponse.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Response {
    
    /// Body of the `Beacon.Response.error` message.
    public struct Error: ResponseProtocol, Equatable, Codable {
        
        /// The value that identifies the request to which the message is responding.
        public let id: String
        
        /// The type of the error.
        public let errorType: Beacon.ErrorType
        
        let version: String
        let requestOrigin: Beacon.Origin
        
        public init(from request: Beacon.Request, errorType: Beacon.ErrorType) {
            self.init(id: request.common.id, errorType: errorType, version: request.common.version, requestOrigin: request.common.origin)
        }
        
        init(id: String, errorType: Beacon.ErrorType, version: String, requestOrigin: Beacon.Origin) {
            self.id = id
            self.errorType = errorType
            self.version = version
            self.requestOrigin = requestOrigin
        }
    }
}
