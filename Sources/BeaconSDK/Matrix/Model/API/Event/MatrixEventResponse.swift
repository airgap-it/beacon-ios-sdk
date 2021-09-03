//
//  MatrixEventResponse.swift
//  BeaconSDK
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix.EventService {
    
    struct EventResponse: Codable {
        let eventID: String?
        
        enum CodingKeys: String, CodingKey {
            case eventID = "event_id"
        }
    }
}
