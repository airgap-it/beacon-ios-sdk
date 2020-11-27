//
//  Transport.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

class Transport {
    final private(set) var status: Status = .notConnected
    private var listeners: Set<Listener> = Set()
    
    // MARK: Connection
    
    final func connect(completion: @escaping (Result<(), Error>) -> ()) {
        guard status != .connected && status != .connecting else {
            return
        }
        
        status = .connecting
        start { result in
            self.status = .connected
            completion(result)
        }
    }
    
    func connect(withNew peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Error>) -> ()) {
        /* no action */
        completion(.success(()))
    }
    
    func disconnect(from peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Error>) -> ()) {
        /* no action */
        completion(.success(()))
    }
    
    func start(completion: @escaping (Result<(), Error>) -> ()) {
        /* no action */
        completion(.success(()))
    }
    
    func send(_ message: ConnectionMessage, to recipient: String? = nil, completion: @escaping (Result<(), Error>) -> ()) {
        /* no action */
        completion(.success(()))
    }
    
    // MARK: Subscription
    
    final func add(listener: Listener) {
        listeners.insert(listener)
    }
    
    final func remove(listener: Listener) {
        listeners.remove(listener)
    }
    
    final func notify(with result: Result<ConnectionMessage, Error>) {
        listeners.forEach { $0.on(value: result) }
    }
    
    // MARK: Types
    
    enum Status {
        case notConnected
        case connecting
        case connected
    }
    
    typealias Listener = DistinguishableListener<Result<ConnectionMessage, Swift.Error>>
}
