//
//  ErrorResponse.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
/// Body of the `BeaconResponse.error` message.
public struct ErrorBeaconResponse<T: Blockchain>: BeaconResponseProtocol, Equatable, Codable {
    
    /// The value that identifies the request to which the message is responding.
    public let id: String
    
    /// The type of the error.
    public let errorType: Beacon.ErrorType<T>
    
    /// The version of the message.
    public let version: String
    
    /// The originiation data of the request.
    public let requestOrigin: Beacon.Origin
    
    public init(from request: BeaconRequestProtocol, errorType: Beacon.ErrorType<T>) {
        self.init(id: request.id, errorType: errorType, version: request.version, requestOrigin: request.origin)
    }
    
    public init(id: String, errorType: Beacon.ErrorType<T>, version: String, requestOrigin: Beacon.Origin) {
        self.id = id
        self.errorType = errorType
        self.version = version
        self.requestOrigin = requestOrigin
    }
}
