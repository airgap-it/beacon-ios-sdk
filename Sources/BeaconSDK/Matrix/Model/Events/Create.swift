//
//  Create.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix.Event {
    
    struct Create {
        let kind: Kind
        let roomID: String
        let creator: String
        
        init(roomID: String, creator: String) {
            kind = .create
            self.roomID = roomID
            self.creator = creator
        }
    }
}
