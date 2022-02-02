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
    
    private var _sendMessageCalls: [Any] = []
    public func sendMessageCalls<B: Blockchain>() -> [BeaconConnectionMessage<B>] {
        _sendMessageCalls.compactMap { $0 as? BeaconConnectionMessage<B> }
    }
    
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
    
    public func listen<B: Blockchain>(onRequest listener: @escaping (Result<BeaconConnectionMessage<B>, Error>) -> ()) {
        listenCalls += 1
        messages
            .compactMap { (origin, message) in
                guard let message = message as? VersionedBeaconMessage<B> else {
                    return nil
                }
                
                return (origin, message)
            }
            .forEach { (origin: Beacon.Origin, message: VersionedBeaconMessage<B>) in
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
    
    public func send<B: Blockchain>(_ message: BeaconConnectionMessage<B>, completion: @escaping (Result<(), Error>) -> ()) {
        _sendMessageCalls.append(message as Any)
        completion(isFailing ? .failure(Beacon.Error.unknown) : .success(()))
    }
    
    public func register<B: Blockchain>(messages: [(Beacon.Origin, VersionedBeaconMessage<B>)]) {
        self.messages.append(contentsOf: messages)
    }
}
