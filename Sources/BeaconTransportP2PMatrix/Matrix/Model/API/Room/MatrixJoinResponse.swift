//
//  MatrixJoinResponse.swift
//  
//
//  Created by Julia Samol on 01.09.21.
//

import Foundation

extension MatrixClient.RoomService {
    
    struct JoinResponse: Codable {
        let userID: String?
        
        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
        }
    }
}
