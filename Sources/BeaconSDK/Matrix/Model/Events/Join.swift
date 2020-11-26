//
//  Join.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix.Event {
    
    struct Join {
        let kind: Kind
        let roomID: String
        let userID: String
        
        init(roomID: String, userID: String) {
            kind = .join
            self.roomID = roomID
            self.userID = userID
        }
    }
}
