//
//  LoginResponse.swift
//  BeaconSDK
//
//  Created by Julia Samol on 17.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix.UserService {
    
    struct LoginResponse: Codable {
        let userID: String?
        let deviceID: String?
        let accessToken: String?
        
        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case deviceID = "device_id"
            case accessToken = "access_token"
        }
    }
}
