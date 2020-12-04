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
    private let storageManager: StorageManager
    private let accountUtils: AccountUtilsProtocol
    private let timeUtils: TimeUtilsProtocol
    
    private var pendingRequests: [String: Beacon.Request] = [:]
    private let queue: DispatchQueue = .init(label: "it.airgap.beacon-sdk.MessageController", attributes: [], target: .global(qos: .default))
    
    init(coinRegistry: CoinRegistryProtocol, storageManager: StorageManager, accountUtils: AccountUtilsProtocol, timeUtils: TimeUtilsProtocol) {
        self.coinRegistry = coinRegistry
        self.storageManager = storageManager
        self.accountUtils = accountUtils
        self.timeUtils = timeUtils
    }
    
    // MARK: Incoming Messages
    
    func onIncoming(
        _ message: Beacon.Message.Versioned,
        with origin: Beacon.Origin,
        completion: @escaping (Result<Beacon.Message, Swift.Error>) -> ()
    ) {
        message.toBeaconMessage(with: origin, using: storageManager) { result in
            guard let beaconMessage = result.get(ifFailure: completion) else { return }
            
            self.onIncoming(beaconMessage) { result in
                guard result.isSuccess(else: completion) else { return }
                completion(.success(beaconMessage))
            }
        }
    }
    
    private func onIncoming(_ message: Beacon.Message, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        switch message {
        case let .request(request):
            self.queue.async {
                self.pendingRequests[message.common.id] = request
                self.onIncoming(request, completion: completion)
            }
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
        storageManager.add([request.appMetadata], completion: completion)
    }
    
    // MARK: Outgoing Messages
    
    func onOutgoing(
        _ message: Beacon.Message,
        with beaconID: String,
        terminal: Bool,
        completion: @escaping (Result<(Beacon.Origin, Beacon.Message.Versioned), Swift.Error>) -> ()
    ) {
        self.onOutgoing(message, terminal: terminal) { result in
            do {
                guard result.isSuccess(else: completion) else { return }
                
                let senderHash = try self.accountUtils.getSenderID(from: try HexString(from: beaconID))
                let versionedMessage = try Beacon.Message.Versioned(from: message, senderID: senderHash)
                
                completion(.success((message.associatedOrigin, versionedMessage)))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func onOutgoing(
        _ message: Beacon.Message,
        terminal: Bool,
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        switch message {
        case let .response(response):
            queue.async {
                guard let request = self.getPendingRequest(forID: message.common.id, keepEntry: !terminal) else {
                    completion(.failure(Beacon.Error.noPendingRequest(id: message.common.id)))
                    return
                }
                
                self.onOutgoing(response, respondingTo: request, completion: completion)
            }
        default:
            /* no action */
            completion(.success(()))
        }
    }
    
    private func onOutgoing(
        _ response: Beacon.Response,
        respondingTo request: Beacon.Request,
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        switch response {
        case let .permission(response):
            onOutgoing(response, respondingTo: request, completion: completion)
        default:
            /* no action */
            completion(.success(()))
        }
    }
    
    private func onOutgoing(
        _ response: Beacon.Response.Permission,
        respondingTo request: Beacon.Request,
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        do {
            let publicKey = response.publicKey
            let address = try coinRegistry.get(.tezos).getAddressFrom(publicKey: publicKey)
            let accountIdentifier = try accountUtils.getAccountIdentifier(forAddress: address, on: response.network)
            
            storageManager.findAppMetadata(where: { request.common.senderID == $0.senderID }) { result in
                do {
                    guard let appMetadataOrNil = result.get(ifFailure: completion) else { return }
                    
                    guard let appMetadata = appMetadataOrNil else {
                        completion(.failure(Error.noMatchingAppMetadata))
                        return
                    }
                    
                    let permissionInfo = Beacon.Permission(
                        accountIdentifier: accountIdentifier,
                        address: address,
                        network: response.network,
                        scopes: response.scopes,
                        senderID: try self.accountUtils.getSenderID(from: try HexString(from: request.common.origin.id)),
                        appMetadata: appMetadata,
                        publicKey: publicKey,
                        connectedAt: self.timeUtils.currentTimeMillis
                    )
                    
                    self.storageManager.add([permissionInfo], completion: completion)
                } catch {
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    private func getPendingRequest(forID id: String, keepEntry: Bool) -> Beacon.Request? {
        if keepEntry {
            return pendingRequests[id]
        } else {
            return pendingRequests.removeValue(forKey: id)
        }
    }
    
    // MARK: Types
    
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
        with beaconID: String,
        terminal: Bool,
        completion: @escaping (Result<(Beacon.Origin, Beacon.Message.Versioned), Error>) -> ()
    )
}
