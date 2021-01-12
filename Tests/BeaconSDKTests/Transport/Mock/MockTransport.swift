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
    private(set) var connectPeersCalls: [[Beacon.Peer]] = []
    private(set) var disconnectPeersCalls: [[Beacon.Peer]] = []
    private(set) var sendMessageCalls: [ConnectionMessage] = []
    
    override func start(completion: @escaping (Result<(), Error>) -> ()) {
        startCalls += 1
        completion(isFailing ? .failure(Beacon.Error.unknown) : .success(()))
    }
    
    override func connect(new peers: [Beacon.Peer], completion: @escaping (Result<[Beacon.Peer], Error>) -> ()) {
        connectPeersCalls.append(peers)
        if isFailing {
            completion(.failure(Beacon.Error.unknown))
        } else {
            let connected = peers.filter {
                switch $0 {
                case .p2p(_):
                    return kind == .p2p
                }
            }
            
            completion(.success(connected))
        }
    }
    
    override func disconnect(from peers: [Beacon.Peer], completion: @escaping (Result<[Beacon.Peer], Error>) -> ()) {
        disconnectPeersCalls.append(peers)
        if isFailing {
            completion(.failure(Beacon.Error.unknown))
        } else {
            let disconnected = peers.filter {
                switch $0 {
                case .p2p(_):
                    return kind == .p2p
                }
            }
            
            completion(.success(disconnected))
        }
    }
    
    override func send(_ message: ConnectionMessage, completion: @escaping (Result<(), Error>) -> ()) {
        sendMessageCalls.append(message)
        completion(.success(()))
    }
}
