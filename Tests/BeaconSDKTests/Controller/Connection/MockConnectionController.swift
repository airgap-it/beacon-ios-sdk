//
//  MockConnectionController.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
@testable import BeaconSDK

class MockConnectionController: ConnectionControllerProtocol {
    var isFailing: Bool = false
    
    private var messages: [(Beacon.Origin, Beacon.Message.Versioned)] = []
    
    func subscribe(
        onRequest listener: @escaping (Result<BeaconConnectionMessage, Swift.Error>) -> (),
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        messages.forEach { (origin, message) in
            if isFailing {
                listener(.failure(Error.unknown))
            } else {
                listener(.success(BeaconConnectionMessage(origin: origin, content: message)))
            }
        }
        completion(.success(()))
    }
    
    func on(new peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Swift.Error>) -> ()) {
        completion(.success(()))
    }
    
    func on(deleted peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Swift.Error>) -> ()) {
        completion(.success(()))
    }
    
    func send(_ message: BeaconConnectionMessage, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        completion(.success(()))
    }
    
    func register(messages: [(Beacon.Origin, Beacon.Message.Versioned)]) {
        self.messages.append(contentsOf: messages)
    }
    
    enum Error: Swift.Error {
        case unknown
    }
}
