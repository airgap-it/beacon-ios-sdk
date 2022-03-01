//
//  AcknowledgeBeaconResponse.swift
//
//
//  Created by Julia Samol on 02.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
/// Body of the `BeaconResponse.acknowledge` message.
public struct AcknowledgeBeaconResponse: BeaconResponseProtocol, Identifiable, Equatable, Codable {
    
    /// The value that identifies the request to which the message is responding.
    public let id: String
    
    /// The version of the message.
    public let version: String
    
    /// The originiation data of the request.
    public let requestOrigin: Beacon.Origin
    
    public init(from request: BeaconRequestProtocol) {
        self.init(id: request.id, version: request.version, requestOrigin: request.origin)
    }
    
    public init(id: String, version: String, requestOrigin: Beacon.Origin) {
        self.id = id
        self.version = version
        self.requestOrigin = requestOrigin
    }
}
