//
//  ErrorResponse.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
/// Body of the `BeaconResponse.error` message.
public struct ErrorBeaconResponse<B: Blockchain>: BeaconResponseProtocol, Identifiable, Equatable, Codable {
    
    /// The value that identifies the request to which the message is responding.
    public let id: String
    
    /// The version of the message.
    public let version: String
    
    /// The originiation data of the request.
    public let requestOrigin: Beacon.Origin
    
    /// The type of the error.
    public let errorType: Beacon.ErrorType<B>
    
    /// Additional and optional details.
    public let description: String?
    
    public init(from request: B.Request.Permission, errorType: Beacon.ErrorType<B>, description: String? = nil) {
        self.init(
            id: request.id,
            version: request.version,
            requestOrigin: request.origin,
            errorType: errorType,
            description: description
        )
    }
    
    public init(from request: B.Request.Blockchain, errorType: Beacon.ErrorType<B>, description: String? = nil) {
        self.init(
            id: request.id,
            version: request.version,
            requestOrigin: request.origin,
            errorType: errorType,
            description: description
        )
    }
    
    public init(
        id: String,
        version: String,
        requestOrigin: Beacon.Origin,
        errorType: Beacon.ErrorType<B>,
        description: String? = nil
    ) {
        self.id = id
        self.version = version
        self.requestOrigin = requestOrigin
        self.errorType = errorType
        self.description = description
    }
}
