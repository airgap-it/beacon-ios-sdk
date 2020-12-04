//
//  MockMessageController.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
@testable import BeaconSDK

class MockMessageController: MessageControllerProtocol {
    var isFailing: Bool
    
    var dAppVersion: String
    var dAppID: String
    
    var connectionKind: Beacon.Connection.Kind
    
    private(set) var onIncomingCalls: [(Beacon.Message.Versioned, Beacon.Origin)] = []
    private(set) var onOutgoingCalls: [(Beacon.Message, String)] = []
    
    private let storageManager: StorageManager
    
    init(storageManager: StorageManager, connectionKind: Beacon.Connection.Kind = .p2p) {
        isFailing = false
        
        dAppVersion = "1"
        dAppID = "mockDApp"
                
        self.storageManager = storageManager
        self.connectionKind = connectionKind
    }
    
    func onIncoming(
        _ message: Beacon.Message.Versioned,
        with origin: Beacon.Origin,
        completion: @escaping (Result<Beacon.Message, Swift.Error>) -> ()
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
    
    func onOutgoing(
        _ message: Beacon.Message,
        with beaconID: String,
        terminal: Bool,
        completion: @escaping (Result<(Beacon.Origin, Beacon.Message.Versioned), Swift.Error>) -> ()
    ) {
        onOutgoingCalls.append((message, beaconID))
        if isFailing {
            completion(.failure(Beacon.Error.unknown))
        } else {
            let result = catchResult {
                try Beacon.Message.Versioned(from: message, senderID: beaconID)
            }.map { ((Beacon.Origin(kind: connectionKind, id: beaconID), $0)) }
            
            completion(result)
        }
    }
}

typealias OnIncomingArguments = (Beacon.Message.Versioned, Beacon.Origin)
func == (lhs: OnIncomingArguments, rhs: OnIncomingArguments) -> Bool {
    lhs.0 == rhs.0 && lhs.1 == rhs.1
}

func == (lhs: [OnIncomingArguments], rhs: [OnIncomingArguments]) -> Bool {
    lhs.elementsEqual(rhs, by: { $0 == $1 })
}

typealias OnOutgoingArguments = (Beacon.Message, String)
func == (lhs: OnOutgoingArguments, rhs: OnOutgoingArguments) -> Bool {
    lhs.0 == rhs.0 && lhs.1 == rhs.1
}

func == (lhs: [OnOutgoingArguments], rhs: [OnOutgoingArguments]) -> Bool {
    lhs.elementsEqual(rhs, by: { $0 == $1 })
}
