//
//  RoomService.swift
//  BeaconSDK
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix {
    
    class RoomService: MatrixService {
        private let http: HTTP
        
        init(http: HTTP) {
            self.http = http
        }
        
        func createRoom(
            on node: String,
            withToken accessToken: String,
            configuredWith createRequest: CreateRequest = CreateRequest(),
            completion: @escaping (Result<CreateResponse, Swift.Error>) -> ()
        ) {
            runCatching(completion: completion) {
                http.post(
                    at: try apiURL(from: node, at: "/createRoom"),
                    body: createRequest,
                    headers: [.bearer(token: accessToken)],
                    throwing: ErrorResponse.self,
                    completion: completion
                )
            }
        }
        
        func joinRoom(
            on node: String,
            withToken accessToken: String,
            roomID: String,
            completion: @escaping (Result<JoinResponse, Swift.Error>) -> ()
        ) {
            runCatching(completion: completion) {
                http.post(
                    at: try apiURL(from: node, at: "/rooms/\(roomID)/join"),
                    body: JoinRequest(),
                    headers: [.bearer(token: accessToken)],
                    throwing: ErrorResponse.self,
                    completion: completion
                )
            }
        }
    }
}
