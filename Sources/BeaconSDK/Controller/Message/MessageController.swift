//
//  MessageController.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

class MessageController: MessageControllerProtocol {
    
    private let coinRegistry: CoinRegistry
    private let storage: ExtendedStorage
    
    init(coinRegistry: CoinRegistry, storage: ExtendedStorage) {
        self.coinRegistry = coinRegistry
        self.storage = storage
    }
    
    // MARK: Incoming messages
    
    func onIncoming(
        _ message: Beacon.Message.Versioned,
        with origin: Beacon.Origin,
        completion: @escaping (Result<Beacon.Message, Swift.Error>) -> ()
    ) {
        message.toBeaconMessage(with: origin, using: storage) { [weak self] result in
            guard let beaconMessage = result.get(ifFailure: completion) else { return }
            switch beaconMessage {
            case let .request(request):
                guard let selfStrong = self else {
                    completion(.failure(Error.unknown))
                    return
                }
                
                selfStrong.onIncoming(request) { result in
                    completion(result.map { beaconMessage })
                }
            default:
                completion(.success(beaconMessage))
                break
            }
        }
    }
    
    private func onIncoming(_ request: Beacon.Request, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        switch request {
        case let .permission(request):
            on(request, completion: completion)
        default:
            /* no action */
            break
        }
    }
        
    private func on(_ request: Beacon.Request.Permission, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.add([request.appMetadata], completion: completion)
    }
    
    // MARK: Outgoing messages
    
    // TODO
    
    enum Error: Swift.Error {
        case unknown
    }
}
