//
//  EventService.swift
//  BeaconSDK
//
//  Created by Julia Samol on 17.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix {
    
    class EventService {
        private let http: HTTP
        
        init(http: HTTP) {
            self.http = http
        }
        
        func sync(
            withToken accessToken: String,
            since: String? = nil,
            timeout: Int64? = nil,
            completion: @escaping (Result<SyncResponse, Swift.Error>) -> ()
        ) {
            var parameters: [(String, String)] = []
            if let since = since {
                parameters.append(("since", since))
            }
            if let timeout = timeout {
                parameters.append(("timeout", String(timeout)))
            }
            
            http.get(at: "/sync", headers: [.bearer(token: accessToken)], parameters: parameters, completion: completion)
        }
        
        func send(
            withToken accessToken: String,
            textMessage message: String,
            to roomID: String,
            txnID: String,
            completion: @escaping (Result<EventResponse, Swift.Error>) -> ()
        ) {
            send(
                withToken: accessToken,
                eventType: .message,
                to: roomID,
                txnID: txnID,
                content: StateEvent.Message.Content(messageType: StateEvent.Message.Kind.text, body: message),
                completion: completion
            )
        }
        
        private func send<T: Codable>(
            withToken accessToken: String,
            eventType: StateEvent.`Type`,
            to roomID: String,
            txnID: String,
            content: T,
            completion: @escaping (Result<EventResponse, Swift.Error>) -> ()) {
            
            http.put(
                at: "/rooms/\(roomID)/send/\(eventType.rawValue)/\(txnID)",
                body: content,
                headers: [.bearer(token: accessToken)],
                completion: completion
            )
        }
    }
}
