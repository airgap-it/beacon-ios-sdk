//
//  DisconnectMessage.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Message {
    
    /// Body of the `Beacon.Message.disconnect` message.
    public struct Disconnect: MessageProtocol, Equatable, Codable {
        
        /// The value that identifies this message.
        public let id: String
        
        /// The value that identifies the sender of this message.
        public let senderID: String
        
        let version: String
        let origin: Beacon.Origin
        
        init(id: String, senderID: String, version: String, origin: Beacon.Origin) {
            self.id = id
            self.senderID = senderID
            self.version = version
            self.origin = origin
        }
    }
}
