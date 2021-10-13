//
//  MatrixCreateStateEvent.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension MatrixClient.EventService.StateEvent {
    
    struct Create: Codable {
        let type: `Type`
        let content: Content?
        let eventID: String?
        let sender: String?
        let stateKey: String?
        
        init(content: Content? = nil, eventID: String? = nil, sender: String? = nil, stateKey: String? = nil) {
            type = .create
            self.content = content
            self.eventID = eventID
            self.sender = sender
            self.stateKey = stateKey
        }
        
        struct Content: Codable {
            let creator: String?
        }
        
        enum CodingKeys: String, CodingKey {
            case type
            case content
            case eventID = "event_id"
            case sender
            case stateKey = "state_key"
        }
    }
}
