//
//  DisconnectMessage.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Message {
    
    /// Body of the `Beacon.Message.disconnect` message
    public struct Disconnect: MessageProtocol, Equatable, Codable {
        
        /// The value that identifies this message.
        public let id: String
        
        /// The value that identifies the sender of this message.
        public let senderID: String
    }
}
