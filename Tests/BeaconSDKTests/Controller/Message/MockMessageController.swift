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
    
    private let storage: ExtendedStorage
    
    init(storage: ExtendedStorage) {
        isFailing = false
        self.storage = storage
    }
    
    func onIncoming(
        _ message: Beacon.Message.Versioned,
        with origin: Beacon.Origin,
        completion: @escaping (Result<Beacon.Message, Swift.Error>) -> ()
    ) {
        if isFailing {
            completion(.failure(Error.unknown))
        } else {
            message.toBeaconMessage(with: origin, using: storage) { beaconMessage in
                completion(beaconMessage)
            }
        }
    }
    
    enum Error: Swift.Error {
        case unknown
    }
}
