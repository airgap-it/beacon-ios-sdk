//
//  MockConnectionController.swift
//  Mocks
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
@testable import BeaconCore

public class MockConnectionController: ConnectionControllerProtocol {
    public var isFailing: Bool = false
    
    public private(set) var connectCalls: Int = 0
    public private(set) var disconnectCalls: Int = 0
    public private(set) var pauseCalls: Int = 0
    public private(set) var resumeCalls: Int = 0
    public private(set) var listenCalls: Int = 0
    public private(set) var onNewPeersCalls: [[Beacon.Peer]] = []
    public private(set) var onDeletedPeerCalls: [[Beacon.Peer]] = []
    
    public var sendMessageCalls: [BeaconConnectionMessage] = []
    
    private var messages: [(Beacon.Origin, Any)] = []
    
    public init() {}
    
    public func connect(completion: @escaping (Result<(), Error>) -> ()) {
        connectCalls += 1
        completion(isFailing ? .failure(Beacon.Error.unknown) : .success(()))
    }
    
    public func disconnect(completion: @escaping (Result<(), Error>) -> ()) {
        disconnectCalls += 1
        completion(isFailing ? .failure(Beacon.Error.unknown) : .success(()))
    }
    
    public func pause(completion: @escaping (Result<(), Error>) -> ()) {
        pauseCalls += 1
        completion(isFailing ? .failure(Beacon.Error.unknown) : .success(()))
    }
    
    public func resume(completion: @escaping (Result<(), Error>) -> ()) {
        resumeCalls += 1
        completion(isFailing ? .failure(Beacon.Error.unknown) : .success(()))
    }
    
    public func listen(onRequest listener: @escaping (Result<BeaconConnectionMessage, Error>) -> ()) {
        listenCalls += 1
        messages
            .compactMap { (origin, message) in
                guard let message = message as? VersionedBeaconMessage else {
                    return nil
                }
                
                return (origin, message)
            }
            .forEach { (origin: Beacon.Origin, message: VersionedBeaconMessage) in
                if isFailing {
                    listener(.failure(Beacon.Error.unknown))
                } else {
                    listener(.success(BeaconConnectionMessage(origin: origin, content: message)))
                }
            }
    }
    
    public func onNew(_ peers: [Beacon.Peer], completion: @escaping (Result<(), Error>) -> ()) {
        onNewPeersCalls.append(peers)
        completion(isFailing ? .failure(Beacon.Error.unknown) : .success(()))
    }
    
    public func onRemoved(_ peers: [Beacon.Peer], completion: @escaping (Result<(), Error>) -> ()) {
        onDeletedPeerCalls.append(peers)
        completion(isFailing ? .failure(Beacon.Error.unknown) : .success(()))
    }
    
    public func send(_ message: BeaconConnectionMessage, completion: @escaping (Result<(), Error>) -> ()) {
        sendMessageCalls.append(message)
        completion(isFailing ? .failure(Beacon.Error.unknown) : .success(()))
    }
    
    public func register(messages: [(Beacon.Origin, VersionedBeaconMessage)]) {
        self.messages.append(contentsOf: messages)
    }
}
