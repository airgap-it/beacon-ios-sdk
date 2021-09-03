//
//  Invite.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix.Event {
    
    struct Invite: EventProtocol {
        let kind: Kind
        let node: String
        let sender: String
        let roomID: String
        
        init(node: String, sender: String, roomID: String) {
            kind = .invite
            self.node = node
            self.sender = sender
            self.roomID = roomID
        }
    }
}
