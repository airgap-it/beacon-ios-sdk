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
    
    /// The destination data of the response.
    public let destination: Beacon.Connection.ID
    
    public init(from request: BeaconRequestProtocol) {
        self.init(id: request.id, version: request.version, destination: request.origin)
    }
    
    public init(id: String, version: String, destination: Beacon.Connection.ID) {
        self.id = id
        self.version = version
        self.destination = destination
    }
}
