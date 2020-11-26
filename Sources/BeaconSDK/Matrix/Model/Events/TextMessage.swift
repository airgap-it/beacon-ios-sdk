//
//  TextMessage.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix.Event {
    
    struct TextMessage {
        let kind: Kind
        let roomID: String
        let sender: String
        let message: String
        
        init(roomID: String, sender: String, message: String) {
            kind = .textMessage
            self.roomID = roomID
            self.sender = sender
            self.message = message
        }
    }
}
