//
//  MemberStateEvent.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix.EventService.StateEvent {
    
    struct Member: Codable {
        let type: `Type`
        let content: Content?
        let eventID: String?
        let sender: String?
        let stateKey: String?
        
        init(content: Content? = nil, eventID: String? = nil, sender: String? = nil, stateKey: String? = nil) {
            type = .member
            self.content = content
            self.eventID = eventID
            self.sender = sender
            self.stateKey = stateKey
        }
        
        struct Content: Codable {
            let membership: Membership
        }
        
        enum Membership: String, Codable {
            case invite
            case join
            case leave
            case ban
            case knock
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
