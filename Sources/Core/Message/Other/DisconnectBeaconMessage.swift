//
//  DisconnectBeaconMessage.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
/// Body of the `BeaconMessage.disconnect` message.
public struct DisconnectBeaconMessage: BeaconMessageProtocol, Identifiable, Equatable, Codable {
    
    /// The value that identifies this message.
    public let id: String
    
    /// The value that identifies the sender of this message.
    public let senderID: String
    
    /// The version of the message.
    public let version: String
    
    /// The origination data of the message.
    public let origin: Beacon.Origin
    
    public init(id: String, senderID: String, version: String, origin: Beacon.Origin) {
        self.id = id
        self.senderID = senderID
        self.version = version
        self.origin = origin
    }
}
