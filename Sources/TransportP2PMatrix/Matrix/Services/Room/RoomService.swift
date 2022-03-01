//
//  RoomService.swift
//  BeaconSDK
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore

extension MatrixClient {
    
    class RoomService: MatrixService {
        
        func createRoom(
            on node: String,
            withToken accessToken: String,
            configuredWith createRequest: CreateRequest = CreateRequest(),
            completion: @escaping (Result<CreateResponse, Swift.Error>) -> ()
        ) {
            runCatching(completion: completion) {
                let url = try apiURL(from: node, at: "/createRoom")
                let call = OngoingCall(method: .post, url: url)
                addOngoing(call)
                
                http.post(
                    at: url,
                    body: createRequest,
                    headers: [.bearer(token: accessToken)],
                    throwing: ErrorResponse.self
                ) { (result: Result<CreateResponse, Swift.Error>) in
                    self.removeOngoing(call)
                    completion(result)
                }
            }
        }
        
        func joinRoom(
            on node: String,
            withToken accessToken: String,
            roomID: String,
            completion: @escaping (Result<JoinResponse, Swift.Error>) -> ()
        ) {
            runCatching(completion: completion) {
                let url = try apiURL(from: node, at: "/rooms/\(roomID)/join")
                let call = OngoingCall(method: .post, url: url)
                addOngoing(call)
                
                http.post(
                    at: url,
                    body: JoinRequest(),
                    headers: [.bearer(token: accessToken)],
                    throwing: ErrorResponse.self
                ) { (result: Result<JoinResponse, Swift.Error>) in
                    self.removeOngoing(call)
                    completion(result)
                }
            }
        }
    }
}
