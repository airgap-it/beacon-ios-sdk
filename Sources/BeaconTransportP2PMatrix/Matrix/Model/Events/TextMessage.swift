//
//  TextMessage.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension MatrixClient.Event {
    
    struct TextMessage: EventProtocol {
        let kind: Kind
        let node: String
        let roomID: String
        let sender: String
        let message: String
        
        init(node: String, roomID: String, sender: String, message: String) {
            kind = .textMessage
            self.node = node
            self.roomID = roomID
            self.sender = sender
            self.message = message
        }
    }
}
