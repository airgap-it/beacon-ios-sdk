//
//  EventService.swift
//  BeaconSDK
//
//  Created by Julia Samol on 17.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix {
    
    class EventService: MatrixService {
        private let http: HTTP
        private lazy var syncSingle: SingleCall<SyncResponse> = SingleCall()
        
        init(http: HTTP) {
            self.http = http
        }
        
        // MARK: Sync
        
        func sync(
            on node: String,
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
            
            guard let apiURL = runCatching(completion: completion, throwing: { try apiURL(from: node, at: "/sync") }) else { return}
            
            syncSingle.run(
                body: {
                    self.http.get(
                        at: apiURL,
                        headers: [.bearer(token: accessToken)],
                        parameters: parameters,
                        throwing: ErrorResponse.self,
                        completion: $0
                    )
                },
                onResult: completion
            )
        }
        
        // MARK: Send
        
        func send(
            on node: String,
            withToken accessToken: String,
            textMessage message: String,
            to roomID: String,
            txnID: String,
            completion: @escaping (Result<EventResponse, Swift.Error>) -> ()
        ) {
            send(
                on: node,
                withToken: accessToken,
                eventType: .message,
                to: roomID,
                txnID: txnID,
                content: StateEvent.Message.Content(messageType: StateEvent.Message.Kind.text, body: message),
                completion: completion
            )
        }
        
        private func send<T: Codable>(
            on node: String,
            withToken accessToken: String,
            eventType: StateEvent.`Type`,
            to roomID: String,
            txnID: String,
            content: T,
            completion: @escaping (Result<EventResponse, Swift.Error>) -> ()) {
            
            runCatching(completion: completion) {
                http.put(
                    at: try apiURL(from: node, at: "/rooms/\(roomID)/send/\(eventType.rawValue)/\(txnID)"),
                    body: content,
                    headers: [.bearer(token: accessToken)],
                    throwing: ErrorResponse.self,
                    completion: completion
                )
            }
        }
    }
}

// MARK: Extensions

private extension Array {
    
    mutating func append(_ newElement: Element?) {
        if let element = newElement {
            append(element)
        }
    }
}
