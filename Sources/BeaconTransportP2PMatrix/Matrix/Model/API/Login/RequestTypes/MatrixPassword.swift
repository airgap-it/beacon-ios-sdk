//
//  MatrixPassword.swift
//  BeaconSDK
//
//  Created by Julia Samol on 17.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension MatrixClient.UserService.LoginRequest {
    
    struct Password: Codable {
        let type: `Type`
        let identifier: UserIdentifier
        let password: String
        let deviceID: String
        
        init(identifier: UserIdentifier, password: String, deviceID: String) {
            type = .password
            self.identifier = identifier
            self.password = password
            self.deviceID = deviceID
        }
        
        enum CodingKeys: String, CodingKey {
            case type
            case identifier
            case password
            case deviceID = "device_id"
        }
    }
}
