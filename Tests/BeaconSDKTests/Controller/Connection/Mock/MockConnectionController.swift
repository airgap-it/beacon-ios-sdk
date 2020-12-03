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
    
    private(set) var connectCalls: Int = 0
    private(set) var listenCalls: Int = 0
    private(set) var onNewPeersCalls: [[Beacon.PeerInfo]] = []
    private(set) var onDeletedPeerCalls: [[Beacon.PeerInfo]] = []
    private(set) var sendMessageCalls: [BeaconConnectionMessage] = []
    
    private var messages: [(Beacon.Origin, Beacon.Message.Versioned)] = []
    
    func connect(completion: @escaping (Result<(), Error>) -> ()) {
        connectCalls += 1
        completion(isFailing ? .failure(Beacon.Error.unknown) : .success(()))
    }
    
    func listen(onRequest listener: @escaping (Result<BeaconConnectionMessage, Error>) -> ()) {
        listenCalls += 1
        messages.forEach { (origin, message) in
            if isFailing {
                listener(.failure(Beacon.Error.unknown))
            } else {
                listener(.success(BeaconConnectionMessage(origin: origin, content: message)))
            }
        }
    }
    
    func onNew(_ peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Error>) -> ()) {
        onNewPeersCalls.append(peers)
        completion(isFailing ? .failure(Beacon.Error.unknown) : .success(()))
    }
    
    func onDeleted(_ peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Error>) -> ()) {
        onDeletedPeerCalls.append(peers)
        completion(isFailing ? .failure(Beacon.Error.unknown) : .success(()))
    }
    
    func send(_ message: BeaconConnectionMessage, completion: @escaping (Result<(), Error>) -> ()) {
        sendMessageCalls.append(message)
        completion(isFailing ? .failure(Beacon.Error.unknown) : .success(()))
    }
    
    func register(messages: [(Beacon.Origin, Beacon.Message.Versioned)]) {
        self.messages.append(contentsOf: messages)
    }
}
