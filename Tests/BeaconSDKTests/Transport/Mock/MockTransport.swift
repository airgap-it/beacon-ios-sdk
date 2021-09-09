//
//  MockTransport.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 01.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
@testable import BeaconSDK

class MockTransport: Transport {
    var isFailing: Bool = false
    
    private(set) var startCalls: Int = 0
    private(set) var stopCalls: Int = 0
    private(set) var pauseCalls: Int = 0
    private(set) var resumeCalls: Int = 0
    private(set) var connectPeersCalls: [[Beacon.Peer]] = []
    private(set) var disconnectPeersCalls: [[Beacon.Peer]] = []
    private(set) var sendMessageCalls: [ConnectionMessage] = []
    
    init(kind: Beacon.Connection.Kind) {
        let wrapped = Wrapped()
        super.init(kind: kind, wrapped: wrapped)
        
        wrapped.owner = self
    }
    
    class Wrapped: TransportProtocol {
        weak var owner: MockTransport?
        
        func start(completion: @escaping (Result<(), Error>) -> ()) {
            guard let mock = owner else {
                completion(.success(()))
                return
            }
            
            mock.startCalls += 1
            completion(mock.isFailing ? .failure(Beacon.Error.unknown) : .success(()))
        }
        
        func stop(completion: @escaping (Result<(), Error>) -> ()) {
            guard let mock = owner else {
                completion(.success(()))
                return
            }
            
            mock.stopCalls += 1
            completion(mock.isFailing ? .failure(Beacon.Error.unknown) : .success(()))
        }
        
        func pause(completion: @escaping (Result<(), Error>) -> ()) {
            guard let mock = owner else {
                completion(.success(()))
                return
            }
            
            mock.pauseCalls += 1
            completion(mock.isFailing ? .failure(Beacon.Error.unknown) : .success(()))
        }
        
        func resume(completion: @escaping (Result<(), Error>) -> ()) {
            guard let mock = owner else {
                completion(.success(()))
                return
            }
            
            mock.resumeCalls += 1
            completion(mock.isFailing ? .failure(Beacon.Error.unknown) : .success(()))
        }
        
        func connect(new peers: [Beacon.Peer], completion: @escaping (Result<[Beacon.Peer], Error>) -> ()) {
            guard let mock = owner else {
                completion(.success(peers))
                return
            }
            
            mock.connectPeersCalls.append(peers)
            if mock.isFailing {
                completion(.failure(Beacon.Error.unknown))
            } else {
                let connected = peers.filter {
                    switch $0 {
                    case .p2p(_):
                        return mock.kind == .p2p
                    }
                }
                
                completion(.success(connected))
            }
        }
        
        func disconnect(from peers: [Beacon.Peer], completion: @escaping (Result<[Beacon.Peer], Error>) -> ()) {
            guard let mock = owner else {
                completion(.success(peers))
                return
            }
            
            mock.disconnectPeersCalls.append(peers)
            if mock.isFailing {
                completion(.failure(Beacon.Error.unknown))
            } else {
                let disconnected = peers.filter {
                    switch $0 {
                    case .p2p(_):
                        return mock.kind == .p2p
                    }
                }
                
                completion(.success(disconnected))
            }
        }
        
        func send(_ message: ConnectionMessage, completion: @escaping (Result<(), Error>) -> ()) {
            guard let mock = owner else {
                completion(.success(()))
                return
            }
            
            mock.sendMessageCalls.append(message)
            completion(.success(()))
        }
    }
}
