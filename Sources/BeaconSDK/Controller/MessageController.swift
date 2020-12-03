//
//  MessageController.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

class MessageController: MessageControllerProtocol {
    
    private let coinRegistry: CoinRegistryProtocol
    private let storage: StorageManager
    private let accountUtils: AccountUtilsProtocol
    private let timeUtils: TimeUtilsProtocol
    
    private var pendingRequests: [String: (Beacon.Origin, Beacon.Message.Versioned)] = [:]
    private let queue: DispatchQueue = .init(label: "it.airgap.beacon-sdk.MessageController", attributes: [], target: .global(qos: .default))
    
    init(coinRegistry: CoinRegistryProtocol, storage: StorageManager, accountUtils: AccountUtilsProtocol, timeUtils: TimeUtilsProtocol) {
        self.coinRegistry = coinRegistry
        self.storage = storage
        self.accountUtils = accountUtils
        self.timeUtils = timeUtils
    }
    
    // MARK: Incoming Messages
    
    func onIncoming(
        _ message: Beacon.Message.Versioned,
        with origin: Beacon.Origin,
        completion: @escaping (Result<Beacon.Message, Swift.Error>) -> ()
    ) {
        message.toBeaconMessage(with: origin, using: storage) { result in
            guard let beaconMessage = result.get(ifFailure: completion) else { return }
            
            self.onIncoming(beaconMessage) { result in
                guard result.isSuccess(else: completion) else { return }
                
                self.queue.async {
                    self.pendingRequests[message.common.id] = (origin, message)
                }

                completion(.success(beaconMessage))
            }
        }
    }
    
    private func onIncoming(_ message: Beacon.Message, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        switch message {
        case let .request(request):
            onIncoming(request, completion: completion)
        default:
            completion(.success(()))
        }
    }
    
    private func onIncoming(_ request: Beacon.Request, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        switch request {
        case let .permission(permissionRequest):
            onIncoming(permissionRequest, completion: completion)
        default:
            /* no action */
            completion(.success(()))
        }
    }
        
    private func onIncoming(_ request: Beacon.Request.Permission, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.add([request.appMetadata], completion: completion)
    }
    
    // MARK: Outgoing Messages
    
    func onOutgoing(
        _ message: Beacon.Message,
        from senderID: String,
        completion: @escaping (Result<(Beacon.Origin, Beacon.Message.Versioned), Swift.Error>) -> ()
    ) {
        queue.async {
            guard let (origin, request) = self.pendingRequests.removeValue(forKey: message.common.id) else {
                completion(.failure(Beacon.Error.noPendingRequest(id: message.common.id)))
                return
            }
            
            self.onOutgoing(message, with: origin, respondingTo: request) { result in
                guard result.isSuccess(else: completion) else { return }
                
                let versionedMessage = Beacon.Message.Versioned(from: message, version: request.common.version, senderID: senderID)
                completion(.success((origin, versionedMessage)))
            }
        }
    }
    
    private func onOutgoing(
        _ message: Beacon.Message,
        with origin: Beacon.Origin,
        respondingTo request: Beacon.Message.Versioned,
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        switch message {
        case let .response(response):
            onOutgoing(response, with: origin, respondingTo: request, completion: completion)
        default:
            /* no action */
            completion(.success(()))
        }
    }
    
    private func onOutgoing(
        _ response: Beacon.Response,
        with origin: Beacon.Origin,
        respondingTo request: Beacon.Message.Versioned,
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        switch response {
        case let .permission(response):
            onOutgoing(response, with: origin, respondingTo: request, completion: completion)
        default:
            /* no action */
            completion(.success(()))
        }
    }
    
    private func onOutgoing(
        _ response: Beacon.Response.Permission,
        with origin: Beacon.Origin,
        respondingTo request: Beacon.Message.Versioned,
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        do {
            let publicKey = response.publicKey
            let address = try coinRegistry.get(.tezos).getAddressFrom(publicKey: publicKey)
            let accountIdentifier = try accountUtils.getAccountIdentifier(forAddress: address, on: response.network)
            
            storage.findAppMetadata(where: { request.common.comesFrom($0) }) { result in
                guard let appMetadataOrNil = result.get(ifFailure: completion) else { return }
                
                guard let appMetadata = appMetadataOrNil else {
                    completion(.failure(Error.noMatchingAppMetadata))
                    return
                }
                
                let permissionInfo = Beacon.PermissionInfo(
                    accountIdentifier: accountIdentifier,
                    address: address,
                    network: response.network,
                    scopes: response.scopes,
                    senderID: origin.id,
                    appMetadata: appMetadata,
                    publicKey: publicKey,
                    connectedAt: self.timeUtils.currentTimeMillis
                )
                
                self.storage.add([permissionInfo], completion: completion)
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    enum Error: Swift.Error {
        case noMatchingAppMetadata
    }
}

// MARK: Protocol

protocol MessageControllerProtocol {
    func onIncoming(
        _ message: Beacon.Message.Versioned,
        with origin: Beacon.Origin,
        completion: @escaping (Result<Beacon.Message, Error>) -> ()
    )
    
    func onOutgoing(
        _ message: Beacon.Message,
        from senderID: String,
        completion: @escaping (Result<(Beacon.Origin, Beacon.Message.Versioned), Error>) -> ()
    )
}
