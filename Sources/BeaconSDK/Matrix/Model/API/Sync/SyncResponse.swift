//
//  SyncResponse.swift
//  BeaconSDK
//
//  Created by Julia Samol on 17.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix.EventService {
    
    struct SyncResponse: Codable {
        let nextBatch: String?
        let rooms: Rooms?
        
        enum CodingKeys: String, CodingKey {
            case nextBatch = "next_batch"
            case rooms
        }
    }
}
