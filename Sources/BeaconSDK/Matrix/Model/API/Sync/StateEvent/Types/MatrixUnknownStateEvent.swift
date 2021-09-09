//
//  MatrixUnknownStateEvent.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix.EventService.StateEvent {
    
    struct Unknown: Codable {
        let type: String?
        let eventID: String?
        let sender: String?
        let stateKey: String?
        
        init(type: String? = nil, eventID: String? = nil, sender: String? = nil, stateKey: String? = nil) {
            self.type = type
            self.eventID = eventID
            self.sender = sender
            self.stateKey = stateKey
        }
        
        enum CodingKeys: String, CodingKey {
            case type
            case eventID = "event_id"
            case sender
            case stateKey = "state_key"
        }
    }
}
