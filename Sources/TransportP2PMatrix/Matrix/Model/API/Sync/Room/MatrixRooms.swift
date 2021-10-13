//
//  MatrixRooms.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension MatrixClient.EventService.SyncResponse {
    
    struct Rooms: Codable {
        let join: [String: Join]?
        let invite: [String: Invite]?
        let leave: [String: Leave]?
        
        struct Join: Codable {
            let state: RoomState?
            let timeline: RoomTimeline?
        }
        
        struct Invite: Codable {
            let state: RoomState?
            
            enum CodingKeys: String, CodingKey {
                case state = "invite_state"
            }
        }
        
        struct Leave: Codable {
            let state: RoomState?
            let timeline: RoomTimeline?
        }
    }
}
