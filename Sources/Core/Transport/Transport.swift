//
//  Transport.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public class Transport {
    let kind: Beacon.Connection.Kind
    
    private let wrapped: TransportProtocol
    
    private var status: Status = .disconnected
    
    @Disposable private var savedMessages: [Result<ConnectionMessage, Swift.Error>]?
    private var listeners: Set<Listener> = []
    
    private var connectedPeers: Set<Beacon.Peer> = []
    
    private let queue: DispatchQueue = .init(label: "it.airgap.beacon-sdk.Transport", attributes: [], target: .global(qos: .default))
    
    init(kind: Beacon.Connection.Kind, wrapped: TransportProtocol) {
        self.kind = kind
        self.wrapped = wrapped
    }
    
    // MARK: Connection
    
    func status(completion: @escaping (Status) -> ()) {
        queue.async {
            completion(self.status)
        }
    }
    
    func connectedPeers(completion: @escaping (Set<Beacon.Peer>) -> ()) {
        queue.async {
            completion(self.connectedPeers)
        }
    }
    
    func start(completion: @escaping (Result<(), Swift.Error>) -> ()) {
        queue.async {
            guard self.status != .connected && self.status != .connecting else {
                completion(.success(()))
                return
            }
            
            guard self.status != .paused else {
                self.resume(completion: completion)
                return
            }
            
            self.status = .connecting
            self.wrapped.start { result in
                self.queue.async {
                    self.status = result.isSuccess ? .connected : .disconnected
                    completion(result)
                }
            }
        }
    }
    
    func stop(completion: @escaping (Result<(), Swift.Error>) -> ()) {
        queue.async {
            guard self.status != .disconnected else {
                completion(.success(()))
                return
            }
            
            self.wrapped.stop { result in
                self.queue.async {
                    if result.isSuccess {
                        self.status = .disconnected
                        self.listeners.removeAll()
                    }
                    completion(result)
                }
            }
        }
    }
    
    func pause(completion: @escaping (Result<(), Swift.Error>) -> ()) {
        queue.async {
            guard self.status == .connected else {
                completion(.success(()))
                return
            }
            
            self.wrapped.pause { result in
                self.queue.async {
                    if result.isSuccess {
                        self.status = .paused
                    }
                    completion(result)
                }
                
            }
        }
    }
    
    func resume(completion: @escaping (Result<(), Swift.Error>) -> ()) {
        queue.async {
            guard self.status == .paused else {
                completion(.success(()))
                return
            }
            
            self.status = .connecting
            self.wrapped.resume { result in
                self.queue.async {
                    if result.isSuccess {
                        self.status = .connected
                    }
                    completion(result)
                }
            }
        }
    }
    
    func disconnect(from peers: [Beacon.Peer], completion: @escaping (Result<(), Swift.Error>) -> ()) {
        wrapped.disconnect(from: peers) { (result: Result<[Beacon.Peer], Swift.Error>) in
            self.queue.async {
                guard let disconnected = result.get(ifFailure: completion) else { return }
                
                let connected = self.connectedPeers.intersection(disconnected)
                self.connectedPeers.formIntersection(connected)
                
                completion(.success(()))
            }
        }
    }
    
    func connect(new peers: [Beacon.Peer], completion: @escaping (Result<(), Swift.Error>) -> ()) {
        start { startResult in
            guard startResult.isSuccess(else: completion) else { return }
            self.wrapped.connect(new: peers) { (connectResult: Result<[Beacon.Peer], Swift.Error>) in
                self.queue.async {
                    guard let connected = connectResult.get(ifFailure: completion) else { return }
                    self.connectedPeers.formUnion(connected)
                
                    completion(.success(()))
                }
            }
        }
    }
    
    func send(_ message: ConnectionMessage, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        wrapped.send(message, completion: completion)
    }
    
    // MARK: Subscription
    
    final func add(_ listener: Listener) {
        listeners.insert(listener)
    }
    
    final func remove(_ listener: Listener) {
        listeners.remove(listener)
    }
    
    final func notify(with result: Result<ConnectionMessage, Swift.Error>) {
        queue.async {
            guard self.status == .connected || self.status == .connecting else {
                self.savedMessages = (self.savedMessages ?? []) + [result]
                return
            }
            
            self.listeners.forEach { listener in
                self.savedMessages?.forEach { listener.notify(with: $0) }
                listener.notify(with: result)
            }
        }
    }
    
    // MARK: Types
    
    enum Status {
        case disconnected
        case connecting
        case connected
        case paused
    }
    
    typealias Listener = DistinguishableListener<Result<ConnectionMessage, Swift.Error>>
}

// MARK: Protocol

protocol TransportProtocol {
    func start(completion: @escaping (Result<(), Swift.Error>) -> ())
    func stop(completion: @escaping (Result<(), Swift.Error>) -> ())
    func pause(completion: @escaping (Result<(), Swift.Error>) -> ())
    func resume(completion: @escaping (Result<(), Swift.Error>) -> ())
    
    func connect(new peers: [Beacon.Peer], completion: @escaping (Result<[Beacon.Peer], Swift.Error>) -> ())
    func disconnect(from peers: [Beacon.Peer], completion: @escaping (Result<[Beacon.Peer], Swift.Error>) -> ())
    
    func send(_ message: ConnectionMessage, completion: @escaping (Result<(), Swift.Error>) -> ())
}
