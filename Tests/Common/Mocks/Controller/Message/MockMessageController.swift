//
//  MockMessageController.swift
//  Mocks
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
@testable import BeaconCore

public class MockMessageController: MessageControllerProtocol {
    public var isFailing: Bool
    
    public var dAppVersion: String
    public var dAppID: String
    
    public var connectionKind: Beacon.Connection.Kind
    
    private var _onIncomingCalls: [(Any, Beacon.Connection.ID)] = []
    public func onIncomingCalls<B: Blockchain>() -> [(VersionedBeaconMessage<B>, Beacon.Connection.ID)] {
        _onIncomingCalls.compactMap {
            guard let versioned = $0.0 as? VersionedBeaconMessage<B> else {
                return nil
            }
            
            return (versioned, $0.1)
        }
    }
    
    private var anyOnOutgoingCalls: [(Any, String)] = []
    public func onOutgoingCalls<T: Blockchain>() -> [(BeaconMessage<T>, String)] {
        anyOnOutgoingCalls.compactMap { (message, senderID) in
            guard let message = message as? BeaconMessage<T> else { return nil }
            return (message, senderID)
        }
    }
    
    private let storageManager: StorageManager
    
    public init(storageManager: StorageManager, connectionKind: Beacon.Connection.Kind = .p2p) {
        isFailing = false
        
        dAppVersion = "1"
        dAppID = "mockDApp"
                
        self.storageManager = storageManager
        self.connectionKind = connectionKind
    }
    
    public func onIncoming<B: Blockchain>(
        _ message: VersionedBeaconMessage<B>,
        withOrigin origin: Beacon.Connection.ID,
        andDestination destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<B>, Swift.Error>) -> ()
    ) {
        _onIncomingCalls.append((message, origin))
        if isFailing {
            completion(.failure(Beacon.Error.unknown()))
        } else {
            message.toBeaconMessage(withOrigin: origin, andDestination: destination) { beaconMessage in
                completion(beaconMessage)
            }
        }
    }
    
    public func onOutgoing<B: Blockchain>(
        _ message: BeaconMessage<B>,
        with beaconID: String,
        terminal: Bool,
        completion: @escaping (Result<(Beacon.Connection.ID, VersionedBeaconMessage<B>), Swift.Error>) -> ()
    ) {
        anyOnOutgoingCalls.append((message, beaconID))
        if isFailing {
            completion(.failure(Beacon.Error.unknown()))
        } else {
            let result: Result<(Beacon.Connection.ID, VersionedBeaconMessage), Swift.Error> = runCatching {
                return try VersionedBeaconMessage(from: message, senderID: beaconID)
            }.map { ((Beacon.Connection.ID(kind: connectionKind, id: beaconID), $0)) }
            
            completion(result)
        }
    }
}

public typealias OnIncomingArguments = (VersionedBeaconMessage<MockBlockchain>, Beacon.Connection.ID)
public func == (lhs: OnIncomingArguments, rhs: OnIncomingArguments) -> Bool {
    lhs.0 == rhs.0 && lhs.1 == rhs.1
}

public func == (lhs: [OnIncomingArguments], rhs: [OnIncomingArguments]) -> Bool {
    lhs.elementsEqual(rhs, by: { $0 == $1 })
}

public typealias OnOutgoingArguments = (BeaconMessage<MockBlockchain>, String)
public func == (lhs: OnOutgoingArguments, rhs: OnOutgoingArguments) -> Bool {
    lhs.0 == rhs.0 && lhs.1 == rhs.1
}

public func == (lhs: [OnOutgoingArguments], rhs: [OnOutgoingArguments]) -> Bool {
    lhs.elementsEqual(rhs, by: { $0 == $1 })
}
