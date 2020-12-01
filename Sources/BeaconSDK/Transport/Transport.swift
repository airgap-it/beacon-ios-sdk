//
//  Transport.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

class Transport {
    let kind: Beacon.Connection.Kind
    
    private var status: Status = .notConnected
    private var listeners: Set<Listener> = Set()
    private var connectedPeers: Set<Beacon.PeerInfo> = Set()
    
    private let queue: DispatchQueue = .init(label: "it.airgap.beacon-sdk.Transport", attributes: [], target: .global(qos: .default))
    
    init(kind: Beacon.Connection.Kind) {
        self.kind = kind
    }
    
    // MARK: Connection
    
    final func status(completion: @escaping (Status) -> ()) {
        queue.async {
            completion(self.status)
        }
    }
    
    final func connectedPeers(completion: @escaping (Set<Beacon.PeerInfo>) -> ()) {
        queue.async {
            completion(self.connectedPeers)
        }
    }
    
    final func connect(completion: @escaping (Result<(), Error>) -> ()) {
        queue.async {
            guard self.status != .connected && self.status != .connecting else {
                return
            }
            
            self.status = .connecting
            self.start { result in
                self.queue.async {
                    self.status = result.isSuccess ? .connected : .notConnected
                }
                completion(result)
            }
        }
    }
    
    final func connect(new peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Error>) -> ()) {
        connect(new: peers) { (result: Result<[Beacon.PeerInfo], Error>) in
            self.queue.async {
                guard let connected = result.get(ifFailure: completion) else { return }
                self.connectedPeers.formUnion(connected)
            
                completion(.success(()))
            }
        }
    }
    
    func connect(new peers: [Beacon.PeerInfo], completion: @escaping (Result<[Beacon.PeerInfo], Error>) -> ()) {
        /* no action */
        completion(.success([]))
    }
    
    final func disconnect(from peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Error>) -> ()) {
        disconnect(from: peers) { (result: Result<[Beacon.PeerInfo], Error>) in
            self.queue.async {
                guard let disconnected = result.get(ifFailure: completion) else { return }
                
                let connected = self.connectedPeers.intersection(disconnected)
                self.connectedPeers.formIntersection(connected)
                
                completion(.success(()))
            }
        }
    }
    
    func disconnect(from peers: [Beacon.PeerInfo], completion: @escaping (Result<[Beacon.PeerInfo], Error>) -> ()) {
        /* no action */
        completion(.success([]))
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
    
    final func add(_ listener: Listener) {
        listeners.insert(listener)
    }
    
    final func remove(_ listener: Listener) {
        listeners.remove(listener)
    }
    
    final func notify(with result: Result<ConnectionMessage, Error>) {
        listeners.forEach { $0.notify(with: result) }
    }
    
    // MARK: Types
    
    enum Status {
        case notConnected
        case connecting
        case connected
    }
    
    typealias Listener = DistinguishableListener<Result<ConnectionMessage, Swift.Error>>
}
