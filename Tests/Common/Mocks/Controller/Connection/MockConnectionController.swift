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
    public func sendMessageCalls<B: Blockchain>() -> [BeaconOutgoingConnectionMessage<B>] {
        _sendMessageCalls.compactMap { $0 as? BeaconOutgoingConnectionMessage<B> }
    }
    
    public private(set) var pairIncomingMessageCalls: [BeaconPairingRequest] = []
    public private(set) var pairOutgoingMessageCalls: [Beacon.Connection.Kind] = []
    
    private var messages: [(Beacon.Connection.ID, Any)] = []
    
    public init() {}
    
    public func connect(completion: @escaping (Result<(), Error>) -> ()) {
        connectCalls += 1
        completion(isFailing ? .failure(Beacon.Error.unknown()) : .success(()))
    }
    
    public func disconnect(completion: @escaping (Result<(), Error>) -> ()) {
        disconnectCalls += 1
        completion(isFailing ? .failure(Beacon.Error.unknown()) : .success(()))
    }
    
    public func pause(completion: @escaping (Result<(), Error>) -> ()) {
        pauseCalls += 1
        completion(isFailing ? .failure(Beacon.Error.unknown()) : .success(()))
    }
    
    public func resume(completion: @escaping (Result<(), Error>) -> ()) {
        resumeCalls += 1
        completion(isFailing ? .failure(Beacon.Error.unknown()) : .success(()))
    }
    
    public func listen<B: Blockchain>(onRequest listener: @escaping (Result<BeaconIncomingConnectionMessage<B>, Error>) -> ()) {
        listenCalls += 1
        messages
            .compactMap { (origin, message) in
                guard let message = message as? VersionedBeaconMessage<B> else {
                    return nil
                }
                
                return (origin, message)
            }
            .forEach { (origin: Beacon.Connection.ID, message: VersionedBeaconMessage<B>) in
                if isFailing {
                    listener(.failure(Beacon.Error.unknown()))
                } else {
                    listener(.success(BeaconIncomingConnectionMessage(origin: origin, content: message)))
                }
            }
    }
    
    public func onNew(_ peers: [Beacon.Peer], completion: @escaping (Result<(), Error>) -> ()) {
        onNewPeersCalls.append(peers)
        completion(isFailing ? .failure(Beacon.Error.unknown()) : .success(()))
    }
    
    public func onRemoved(_ peers: [Beacon.Peer], completion: @escaping (Result<(), Error>) -> ()) {
        onDeletedPeerCalls.append(peers)
        completion(isFailing ? .failure(Beacon.Error.unknown()) : .success(()))
    }
    
    public func send<B: Blockchain>(_ message: BeaconOutgoingConnectionMessage<B>, completion: @escaping (Result<(), Error>) -> ()) {
        _sendMessageCalls.append(message as Any)
        completion(isFailing ? .failure(Beacon.Error.unknown()) : .success(()))
    }
    
    public func register<B: Blockchain>(messages: [(Beacon.Connection.ID, VersionedBeaconMessage<B>)]) {
        self.messages.append(contentsOf: messages)
    }
    
    public func pair(using connectionKind: Beacon.Connection.Kind, onMessage listener: @escaping (Result<BeaconPairingMessage, Error>) -> ()) {
        pairOutgoingMessageCalls.append(connectionKind)
        
        let response = BeaconPairingResponse.p2p(.init(
            id: "id",
            name: "name",
            version: "version",
            publicKey: "00",
            relayServer: "",
            icon: nil,
            appURL: nil
        ))
        
        listener(.success(.response(response)))
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
        
        pairIncomingMessageCalls.append(pairingRequest)
        completion(.success(response))
    }
}
