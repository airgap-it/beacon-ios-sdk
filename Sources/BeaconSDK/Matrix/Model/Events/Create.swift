//
//  Create.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix.Event {
    
    struct Create: EventProtocol {
        let kind: Kind
        let node: String
        let roomID: String
        let creator: String
        
        init(node: String, roomID: String, creator: String) {
            kind = .create
            self.node = node
            self.roomID = roomID
            self.creator = creator
        }
    }
}
