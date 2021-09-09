//
//  MatrixUser.swift
//  BeaconSDK
//
//  Created by Julia Samol on 17.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix.UserService.LoginRequest.UserIdentifier {
    
    struct User: Codable {
        let type: `Type`
        let user: String
        
        init(user: String) {
            type = .user
            self.user = user
        }
    }
}
