//
//  Sync.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix {
    
    struct Sync {
        let nextBatch: String?
        let rooms: [Room]?
        let events: [Event]?
        
        init(nextBatch: String? = nil, rooms: [Room]? = nil, events: [Event]? = nil) {
            self.nextBatch = nextBatch
            self.rooms = rooms
            self.events = events
        }
        
        init(from sync: EventService.SyncResponse) {
            self.nextBatch = sync.nextBatch
            
            self.rooms = {
                if let rooms = sync.rooms {
                    return Room.from(sync: rooms)
                } else {
                    return []
                }
            }()
            
            self.events = {
                if let rooms = sync.rooms {
                    return Event.from(syncRooms: rooms)
                } else {
                    return []
                }
            }()
        }
    }
}
