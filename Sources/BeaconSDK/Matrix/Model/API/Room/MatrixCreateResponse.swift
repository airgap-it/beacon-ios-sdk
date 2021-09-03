//
//  MatrixCreateResponse.swift
//  BeaconSDK
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix.RoomService {
    
    struct CreateResponse: Codable {
        let roomID: String?
        
        enum CodingKeys: String, CodingKey {
            case roomID = "room_id"
        }
    }
}
