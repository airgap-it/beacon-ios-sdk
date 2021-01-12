//
//  UserService.swift
//  BeaconSDK
//
//  Created by Julia Samol on 17.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix {
    
    class UserService {
        private let http: HTTP
        
        init(http: HTTP) {
            self.http = http
        }
        
        func login(user: String, password: String, deviceID: String, completion: @escaping (Result<LoginResponse, Swift.Error>) -> ()) {
            http.post(
                at: "/login",
                body: LoginRequest.password(user: user, password: password, deviceID: deviceID),
                completion: completion
            )
        }
    }
}
