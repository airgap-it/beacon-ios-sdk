//
//  UserService.swift
//  BeaconSDK
//
//  Created by Julia Samol on 17.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore

extension MatrixClient {
    
    class UserService: MatrixService {
        
        func login(
            on node: String,
            user: String,
            password: String,
            deviceID: String,
            completion: @escaping (Result<LoginResponse, Swift.Error>) -> ()
        ) {
            runCatching(completion: completion) {
                let url = try apiURL(from: node, at: "/login")
                let call = OngoingCall(method: .post, url: url)
                addOngoing(call)
                
                http.post(
                    at: url,
                    body: LoginRequest.password(user: user, password: password, deviceID: deviceID),
                    throwing: ErrorResponse.self
                ) { (result: Result<LoginResponse, Swift.Error>) in
                    self.removeOngoing(call)
                    completion(result)
                }
            }
        }
    }
}
