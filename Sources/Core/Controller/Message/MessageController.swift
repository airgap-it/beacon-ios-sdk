//
//  MessageController.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

class MessageController: MessageControllerProtocol {
    
    private let blockchainRegistry: BlockchainRegistryProtocol
    private let storageManager: StorageManager
    private let identifierCreator: IdentifierCreatorProtocol
    private let time: TimeProtocol
    
    private var pendingRequests: [String: BeaconRequestProtocol] = [:]
    private let queue: DispatchQueue = .init(label: "it.airgap.beacon-sdk.MessageController", attributes: [], target: .global(qos: .default))
    
    init(blockchainRegistry: BlockchainRegistryProtocol, storageManager: StorageManager, identifierCreator: IdentifierCreatorProtocol, time: TimeProtocol) {
        self.blockchainRegistry = blockchainRegistry
        self.storageManager = storageManager
        self.identifierCreator = identifierCreator
        self.time = time
    }
    
    // MARK: Incoming Messages
    
    func onIncoming<B: Blockchain>(
        _ message: VersionedBeaconMessage<B>,
        withOrigin origin: Beacon.Connection.ID,
        andDestination destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<B>, Swift.Error>) -> ()
    ) {
        message.toBeaconMessage(withOrigin: origin, andDestination: destination) { (result: Result<BeaconMessage<B>, Swift.Error>) in
            guard let beaconMessage = result.get(ifFailure: completion) else { return }
            
            self.onIncoming(beaconMessage) { result in
                guard result.isSuccess(else: completion) else { return }
                completion(.success(beaconMessage))
            }
        }
    }
    
    private func onIncoming<B: Blockchain>(_ message: BeaconMessage<B>, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        switch message {
        case let .request(request):
            self.queue.async {
                self.savePendingRequest(request)
                self.onIncoming(request, completion: completion)
            }
        default:
            completion(.success(()))
        }
    }
    
    private func onIncoming<B: Blockchain>(_ request: BeaconRequest<B>, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        switch request {
        case let .permission(permissionRequest):
            onIncoming(permissionRequest, ofType: B.self, completion: completion)
        default:
            /* no action */
            completion(.success(()))
        }
    }
        
    private func onIncoming<B: Blockchain>(_ request: B.Request.Permission, ofType type: B.Type, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storageManager.add([request.appMetadata], overwrite: true, completion: completion)
    }
    
    // MARK: Outgoing Messages
    
    func onOutgoing<B: Blockchain>(
        _ message: BeaconMessage<B>,
        with beaconID: String,
        terminal: Bool,
        completion: @escaping (Result<(Beacon.Connection.ID, VersionedBeaconMessage<B>), Swift.Error>) -> ()
    ) {
        self.onOutgoing(message, terminal: terminal) { result in
            do {
                guard result.isSuccess(else: completion) else { return }
                
                let senderHash = try self.identifierCreator.senderID(from: try HexString(from: beaconID))
                let versionedMessage = try VersionedBeaconMessage(from: message, senderID: senderHash)
                
                completion(.success((message.destination, versionedMessage)))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func onOutgoing<B: Blockchain>(
        _ message: BeaconMessage<B>,
        terminal: Bool,
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        switch message {
        case let .response(response):
            queue.async {
                guard let request: BeaconRequest<B> = self.getPendingRequest(forID: message.id, keepEntry: !terminal) else {
                    completion(.failure(Beacon.Error.noPendingRequest(id: message.id)))
                    return
                }
                
                self.onOutgoing(response, respondingTo: request, completion: completion)
            }
        default:
            /* no action */
            completion(.success(()))
        }
    }
    
    private func onOutgoing<B: Blockchain>(
        _ response: BeaconResponse<B>,
        respondingTo request: BeaconRequest<B>,
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        do {
            switch response {
            case let .permission(response):
                guard let request: B.Request.Permission = {
                    switch request {
                    case let .permission(content):
                        return content
                    case .blockchain(_):
                        return nil
                    }
                }() else { throw Error.invalidRequest }
                onOutgoing(response, ofType: B.self, respondingTo: request, completion: completion)
            default:
                /* no action */
                completion(.success(()))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    private func onOutgoing<B: Blockchain>(
        _ response: B.Response.Permission,
        ofType type: B.Type,
        respondingTo request: B.Request.Permission,
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        do {
            guard let blockchain: B = blockchainRegistry.get() else {
                throw Beacon.Error.blockchainNotFound(type.identifier)
            }
            
            blockchain.creator.extractOutgoingPermission(from: request, and: response) { result in
                guard let permissions = result.get(ifFailure: completion) else { return }
                self.storageManager.add(
                    permissions,
                    overwrite: true,
                    distinguishBy: { [$0.accountID, $0.senderID] },
                    completion: completion
                )
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    private func savePendingRequest<B: Blockchain>(_ request: BeaconRequest<B>) {
        pendingRequests[request.id] = request
    }
    
    private func getPendingRequest<B: Blockchain>(forID id: String, keepEntry: Bool) -> BeaconRequest<B>? {
        if keepEntry {
            return pendingRequests[id] as? BeaconRequest<B>
        } else {
            return pendingRequests.removeValue(forKey: id) as? BeaconRequest<B>
        }
    }
    
    // MARK: Types
    
    enum Error: Swift.Error {
        case invalidRequest
    }
}

// MARK: Protocol

public protocol MessageControllerProtocol {
    func onIncoming<B: Blockchain>(
        _ message: VersionedBeaconMessage<B>,
        withOrigin origin: Beacon.Connection.ID,
        andDestination destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<B>, Error>) -> ()
    )
    
    func onOutgoing<B: Blockchain>(
        _ message: BeaconMessage<B>,
        with beaconID: String,
        terminal: Bool,
        completion: @escaping (Result<(Beacon.Connection.ID, VersionedBeaconMessage<B>), Error>) -> ()
    )
}
