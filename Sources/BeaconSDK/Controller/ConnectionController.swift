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
    
    func connect(completion: @escaping (Result<(), Error>) -> ()) {
        transports.forEachAsync(body: { $0.connect(completion: $1) }) { results in
            guard results.allSatisfy({ $0.isSuccess }) else {
                let (notConnected, errors) = results.enumerated()
                    .map { (index, result) in (self.transports[index].kind, result.error) }
                    .filter { (_, error) in error != nil }
                    .unzip()
                
                completion(.failure(Beacon.Error.connectionFailed(notConnected, causedBy: errors.compactMap { $0 })))
                
                return
            }
            
            completion(.success(()))
        }
    }
    
    func listen(onRequest listener: @escaping (Result<BeaconConnectionMessage, Error>) -> ()) {
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
        
        transports.forEach { $0.add(listener) }
    }
    
    func onNew(_ peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Error>) -> ()) {
        transports.forEachAsync(body: { $0.connect(new: peers, completion: $1) }) { (results: [Result<(), Error>]) in
            guard results.allSatisfy({ $0.isSuccess }) else {
                self.transports.forEachAsync(body: { $0.connectedPeers(completion: $1) }) { connectedPeers in
                    let connected = connectedPeers.compactMap { $0 }.flatMap { $0 }
                    let notConnected = peers.filter { !connected.contains($0) }
                    
                    completion(.failure(Beacon.Error.peersNotConnected(notConnected, causedBy: results.compactMap { $0.error })))
                }
                
                return
            }
            
            completion(.success(()))
        }
    }
    
    func onDeleted(_ peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Error>) -> ()) {
        transports.forEachAsync(body: { $0.disconnect(from: peers, completion: $1) }) { (results: [Result<(), Error>]) in
            guard results.allSatisfy({ $0.isSuccess }) else {
                self.transports.forEachAsync(body: { $0.connectedPeers(completion: $1) }) { connectedPeers in
                    let connected = connectedPeers.compactMap { $0 }.flatMap { $0 }
                    let notDisconnected = peers.filter { connected.contains($0) }
                    
                    completion(.failure(Beacon.Error.peersNotDisconnected(notDisconnected, causedBy: results.compactMap { $0.error })))
                }
                
                return
            }
            
            completion(.success(()))
        }
    }
    
    // MARK: Send
    
    func send(
        _ message: BeaconConnectionMessage,
        completion: @escaping (Result<(), Error>) -> ()
    ) {
        do {
            let serialized = try serializer.serialize(message: message.content)
            let serializedConnectionMessage = SerializedConnectionMessage(origin: message.origin, content: serialized)
            
            transports.forEachAsync(body: { $0.send(.serialized(serializedConnectionMessage), completion: $1) }) { results in
                guard results.allSatisfy({ $0.isSuccess }) else {
                    let (notSent, errors) = results.enumerated()
                        .map { (index, result) in (self.transports[index].kind, result.error) }
                        .filter { (_, error) in error != nil }
                        .unzip()
                    
                    completion(.failure(Beacon.Error.sendFailed(notSent, causedBy: errors.compactMap { $0 })))
                    return
                }
                
                completion(.success(()))
            }
        } catch {
            completion(.failure(error))
        }
    }
}

protocol ConnectionControllerProtocol {
    func connect(completion: @escaping (Result<(), Error>) -> ())
    func listen(onRequest listener: @escaping (Result<BeaconConnectionMessage, Error>) -> ())
    func send(_ message: BeaconConnectionMessage, completion: @escaping (Result<(), Error>) -> ())
    
    func onNew(_ peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Error>) -> ())
    func onDeleted(_ peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Error>) -> ())
}
