//
//  RoomService.swift
//  BeaconSDK
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix {
    
    class RoomService {
        private let http: HTTP
        
        init(http: HTTP) {
            self.http = http
        }
        
        func createRoom(
            withToken accessToken: String,
            configuredWith roomConfiguration: CreateRequest = CreateRequest(),
            completion: @escaping (Result<CreateResponse, Swift.Error>) -> ()
        ) {
            http.post(at: "/createRoom", body: roomConfiguration, headers: [.bearer(token: accessToken)], completion: completion)
        }
    }
}
