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
    
    public var onIncomingCalls: [(VersionedBeaconMessage, Beacon.Origin)] = []
    
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
    
    public func onIncoming<T: Blockchain>(
        _ message: VersionedBeaconMessage,
        with origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<T>, Swift.Error>) -> ()
    ) {
        onIncomingCalls.append((message, origin))
        if isFailing {
            completion(.failure(Beacon.Error.unknown))
        } else {
            message.toBeaconMessage(with: origin, using: storageManager) { beaconMessage in
                completion(beaconMessage)
            }
        }
    }
    
    public func onOutgoing<T: Blockchain>(
        _ message: BeaconMessage<T>,
        with beaconID: String,
        terminal: Bool,
        completion: @escaping (Result<(Beacon.Origin, VersionedBeaconMessage), Swift.Error>) -> ()
    ) {
        anyOnOutgoingCalls.append((message, beaconID))
        if isFailing {
            completion(.failure(Beacon.Error.unknown))
        } else {
            let result: Result<(Beacon.Origin, VersionedBeaconMessage), Swift.Error> = runCatching {
                return try VersionedBeaconMessage(from: message, senderID: beaconID)
            }.map { ((Beacon.Origin(kind: connectionKind, id: beaconID), $0)) }
            
            completion(result)
        }
    }
}

public typealias OnIncomingArguments = (VersionedBeaconMessage, Beacon.Origin)
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
