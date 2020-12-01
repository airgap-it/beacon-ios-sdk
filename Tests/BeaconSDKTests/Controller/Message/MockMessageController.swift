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
    
    private let storage: StorageManager
    
    init(storage: StorageManager) {
        isFailing = false
        
        dAppVersion = "1"
        dAppID = "mockDApp"
        
        self.storage = storage
    }
    
    func onIncoming(
        _ message: Beacon.Message.Versioned,
        with origin: Beacon.Origin,
        completion: @escaping (Result<Beacon.Message, Swift.Error>) -> ()
    ) {
        if isFailing {
            completion(.failure(Beacon.Error.unknown))
        } else {
            message.toBeaconMessage(with: origin, using: storage) { beaconMessage in
                completion(beaconMessage)
            }
        }
    }
    
    func onOutgoing(
        _ message: Beacon.Message,
        from senderID: String,
        completion: @escaping (Result<(Beacon.Origin, Beacon.Message.Versioned), Swift.Error>) -> ()
    ) {
        if isFailing {
            completion(.failure(Beacon.Error.unknown))
        } else {
            let versionedMessage = Beacon.Message.Versioned(from: message, version: dAppVersion, senderID: senderID)
            completion(.success((Beacon.Origin(kind: .p2p, id: senderID), versionedMessage)))
        }
    }
}
