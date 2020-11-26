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
    private let accountUtils: AccountUtils
    
    private var pendingRequests: [String: (Beacon.Origin, Beacon.Message.Versioned)] = [:]
    
    init(coinRegistry: CoinRegistry, storage: ExtendedStorage, accountUtils: AccountUtils) {
        self.coinRegistry = coinRegistry
        self.storage = storage
        self.accountUtils = accountUtils
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
                guard result.isSuccess(otherwise: completion) else { return }
                
                self.pendingRequests[message.identifer] = (origin, message)

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
        case let .permission(request):
            onIncoming(request, completion: completion)
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
        guard let (origin, request) = pendingRequests.removeValue(forKey: message.identifier) else {
            completion(.failure(Error.noPendingRequest))
            return
        }
        
        onOutgoing(message, with: origin, respondingTo: request) { result in
            guard result.isSuccess(otherwise: completion) else { return }
            
            let versionedMessage = Beacon.Message.Versioned(from: message, version: request.version, senderID: senderID)
            completion(.success((origin, versionedMessage)))
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
            let accountIdentifier = try accountUtils.getAccountIdentifier(for: address, on: response.network)
            
            storage.findAppMetadata(where: { request.comesFrom(appMetadata: $0) }) { result in
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
                    connectedAt: Date().currentTimeMillis
                )
                
                self.storage.add([permissionInfo], completion: completion)
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    enum Error: Swift.Error {
        case noPendingRequest
        case noMatchingAppMetadata
        case unknown
    }
}
