//
//  MatrixMessageStateEvent.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix.EventService.StateEvent {
    
    struct Message: Codable {
        let type: `Type`
        let content: Content?
        let eventID: String?
        let sender: String?
        let stateKey: String?
        
        init(content: Content? = nil, eventID: String? = nil, sender: String? = nil, stateKey: String? = nil) {
            type = .message
            self.content = content
            self.eventID = eventID
            self.sender = sender
            self.stateKey = stateKey
        }
        
        struct Content: Codable {
            let messageType: String?
            let body: String?
            
            init(messageType: String?, body: String?) {
                self.messageType = messageType
                self.body = body
            }
            
            init(messageType: Kind?, body: String?) {
                self.init(messageType: messageType?.rawValue, body: body)
            }
            
            enum CodingKeys: String, CodingKey {
                case messageType = "msgtype"
                case body
            }
        }
        
        enum Kind: String {
            case text = "m.text"
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
