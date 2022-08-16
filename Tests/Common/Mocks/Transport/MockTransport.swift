//
//  MockTransport.swift
//  Mocks
//
//  Created by Julia Samol on 01.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
@testable import BeaconCore
import BeaconBlockchainTezos

public class MockTransport: Transport {
    public var isFailing: Bool = false
    
    public private(set) var startCalls: Int = 0
    public private(set) var stopCalls: Int = 0
    public private(set) var pauseCalls: Int = 0
    public private(set) var resumeCalls: Int = 0
    public private(set) var connectPeersCalls: [[Beacon.Peer]] = []
    public private(set) var disconnectPeersCalls: [[Beacon.Peer]] = []
    
    public private(set) var sendMessageCalls: [SerializedOutgoingConnectionMessage] = []
    
    public private(set) var pairIncomingMessageCalls: [BeaconPairingRequest] = []
    public private(set) var pairOutgoingMessageCalls: Int = 0
    
    public init(kind: Beacon.Connection.Kind) {
        let wrapped = Wrapped()
        super.init(kind: kind, wrapped: wrapped)
        
        wrapped.owner = self
    }
    
    public class Wrapped: TransportProtocol {
        public weak var owner: MockTransport?
        
        public func start(completion: @escaping (Result<(), Error>) -> ()) {
            guard let mock = owner else {
                completion(.success(()))
                return
            }
            
            mock.startCalls += 1
            completion(mock.isFailing ? .failure(Beacon.Error.unknown()) : .success(()))
        }
        
        public func stop(completion: @escaping (Result<(), Error>) -> ()) {
            guard let mock = owner else {
                completion(.success(()))
                return
            }
            
            mock.stopCalls += 1
            completion(mock.isFailing ? .failure(Beacon.Error.unknown()) : .success(()))
        }
        
        public func pause(completion: @escaping (Result<(), Error>) -> ()) {
            guard let mock = owner else {
                completion(.success(()))
                return
            }
            
            mock.pauseCalls += 1
            completion(mock.isFailing ? .failure(Beacon.Error.unknown()) : .success(()))
        }
        
        public func resume(completion: @escaping (Result<(), Error>) -> ()) {
            guard let mock = owner else {
                completion(.success(()))
                return
            }
            
            mock.resumeCalls += 1
            completion(mock.isFailing ? .failure(Beacon.Error.unknown()) : .success(()))
        }
        
        public func connect(new peers: [Beacon.Peer], completion: @escaping (Result<[Beacon.Peer], Error>) -> ()) {
            guard let mock = owner else {
                completion(.success(peers))
                return
            }
            
            mock.connectPeersCalls.append(peers)
            if mock.isFailing {
                completion(.failure(Beacon.Error.unknown()))
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
        
        public func disconnect(from peers: [Beacon.Peer], completion: @escaping (Result<[Beacon.Peer], Error>) -> ()) {
            guard let mock = owner else {
                completion(.success(peers))
                return
            }
            
            mock.disconnectPeersCalls.append(peers)
            if mock.isFailing {
                completion(.failure(Beacon.Error.unknown()))
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
        
        public func send(_ message: SerializedOutgoingConnectionMessage, completion: @escaping (Result<(), Error>) -> ()) {
            guard let mock = owner else {
                completion(.success(()))
                return
            }
            
            mock.sendMessageCalls.append(message)
            completion(.success(()))
        }
        
        public func supportsPairing(for pairingRequest: BeaconPairingRequest) -> Bool {
            true
        }
        
        public func pair() {
            guard let mock = owner else {
                return
            }
            
            mock.pairOutgoingMessageCalls += 1
        }
        
        public func pair(with pairingRequest: BeaconPairingRequest, completion: @escaping (Result<BeaconPairingResponse, Error>) -> ()) {
            let response = BeaconPairingResponse.p2p(.init(
                id: pairingRequest.id,
                name: pairingRequest.name,
                version: pairingRequest.version,
                publicKey: pairingRequest.publicKey,
                relayServer: "",
                icon: nil,
                appURL: nil
            ))
            
            guard let mock = owner else {
                completion(.success(response))
                return
            }
            
            mock.pairIncomingMessageCalls.append(pairingRequest)
            completion(.success(response))
        }
    }
}
