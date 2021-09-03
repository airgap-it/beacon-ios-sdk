//
//  UserService.swift
//  BeaconSDK
//
//  Created by Julia Samol on 17.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix {
    
    class UserService: MatrixService {
        private let http: HTTP
        
        init(http: HTTP) {
            self.http = http
        }
        
        func login(
            on node: String,
            user: String,
            password: String,
            deviceID: String,
            completion: @escaping (Result<LoginResponse, Swift.Error>) -> ()
        ) {
            runCatching(completion: completion) {
                http.post(
                    at: try apiURL(from: node, at: "/login"),
                    body: LoginRequest.password(user: user, password: password, deviceID: deviceID),
                    throwing: ErrorResponse.self,
                    completion: completion
                )
            }
        }
    }
}
