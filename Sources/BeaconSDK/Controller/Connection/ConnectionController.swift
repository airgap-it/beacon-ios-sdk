//
//  ConnectionController.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

class ConnectionController: ConnectionControllerProtocol {
    private let transports: [Transport]
    private let serializer: Serializer
    
    init(transports: [Transport], serializer: Serializer) {
        self.transports = transports
        self.serializer = serializer
    }
    
    // MARK: Subscription
    
    func subscribe(onRequest listener: @escaping (Result<BeaconConnectionMessage, Error>) -> (), completion: @escaping (Result<(), Error>) -> ()) {
        transports.awaitAll(async: { $0.connect(completion: $1) }) { [weak self] result in
            guard result.isSuccess(otherwise: completion) else { return }
            
            self?.listen(onRequest: listener)
            completion(.success(()))
        }
    }
    
    func on(new peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Error>) -> ()) {
        transports.awaitAll(async: { $0.connect(withNew: peers, completion: $1) }, completion: completion)
    }
    
    private func listen(onRequest listener: @escaping (Result<BeaconConnectionMessage, Error>) -> ()) {
        let listener = Transport.Listener { [weak self] connectionMessage in
            guard let selfStrong = self else {
                return
            }
            
            let result: Result<BeaconConnectionMessage, Error> = connectionMessage.flatMap {
                switch $0 {
                case let .serialized(message):
                    let versioned = catchResult { try selfStrong.serializer.deserialize(message: message.content, to: Beacon.Message.Versioned.self) }
                    
                    return versioned.map { BeaconConnectionMessage(origin: message.origin, content: $0) }
                case let .beacon(message):
                    return .success(message)
                }
            }
            
            listener(result)
        }
        
        transports.forEach { $0.add(listener: listener) }
    }
    
    // MARK: Send
    
    func send(
        _ message: BeaconConnectionMessage,
        completion: @escaping (Result<(), Error>) -> ()
    ) {
        do {
            let serialized = try serializer.serialize(message: message.content)
            let serializedConnectionMessage = SerializedConnectionMessage(origin: message.origin, content: serialized)
            
            transports.awaitAll(async: { $0.send(.serialized(serializedConnectionMessage), completion: $1) }, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
}
