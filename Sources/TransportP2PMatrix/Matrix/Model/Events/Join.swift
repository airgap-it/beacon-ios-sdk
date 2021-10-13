//
//  Join.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension MatrixClient.Event {
    
    struct Join: EventProtocol {
        let kind: Kind
        let node: String
        let roomID: String
        let userID: String
        
        init(node: String, roomID: String, userID: String) {
            kind = .join
            self.node = node
            self.roomID = roomID
            self.userID = userID
        }
    }
}
