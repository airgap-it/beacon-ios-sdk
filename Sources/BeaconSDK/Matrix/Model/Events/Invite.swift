//
//  Invite.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix.Event {
    
    struct Invite {
        let kind: Kind
        let roomID: String
        
        init(roomID: String) {
            kind = .invite
            self.roomID = roomID
        }
    }
}
