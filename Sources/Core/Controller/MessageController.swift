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
    
    func onIncoming<T: Blockchain>(
        _ message: VersionedBeaconMessage,
        with origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<T>, Swift.Error>) -> ()
    ) {
        message.toBeaconMessage(with: origin) { (result: Result<BeaconMessage<T>, Swift.Error>) in
            guard let beaconMessage = result.get(ifFailure: completion) else { return }
            
            self.onIncoming(beaconMessage) { result in
                guard result.isSuccess(else: completion) else { return }
                completion(.success(beaconMessage))
            }
        }
    }
    
    private func onIncoming<T: Blockchain>(_ message: BeaconMessage<T>, completion: @escaping (Result<(), Swift.Error>) -> ()) {
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
    
    private func onIncoming<T: Blockchain>(_ request: BeaconRequest<T>, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        switch request {
        case let .permission(permissionRequest):
            onIncoming(permissionRequest, ofType: T.self, completion: completion)
        default:
            /* no action */
            completion(.success(()))
        }
    }
        
    private func onIncoming<T: Blockchain>(_ request: T.Request.Permission, ofType type: T.Type, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storageManager.add([request.appMetadata], completion: completion)
    }
    
    // MARK: Outgoing Messages
    
    func onOutgoing<T: Blockchain>(
        _ message: BeaconMessage<T>,
        with beaconID: String,
        terminal: Bool,
        completion: @escaping (Result<(Beacon.Origin, VersionedBeaconMessage), Swift.Error>) -> ()
    ) {
        self.onOutgoing(message, terminal: terminal) { result in
            do {
                guard result.isSuccess(else: completion) else { return }
                
                let senderHash = try self.identifierCreator.senderIdentifier(from: try HexString(from: beaconID))
                let versionedMessage = try VersionedBeaconMessage(from: message, senderID: senderHash)
                
                completion(.success((message.associatedOrigin, versionedMessage)))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func onOutgoing(_ message: DisconnectBeaconMessage, with beaconID: String) throws -> (Beacon.Origin, VersionedBeaconMessage) {
        let senderHash = try self.identifierCreator.senderIdentifier(from: try HexString(from: beaconID))
        let versionedMessage = try VersionedBeaconMessage(from: message, senderID: senderHash)
        
        return (message.origin, versionedMessage)
    }
    
    private func onOutgoing<T: Blockchain>(
        _ message: BeaconMessage<T>,
        terminal: Bool,
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        switch message {
        case let .response(response):
            queue.async {
                guard let request: BeaconRequest<T> = self.getPendingRequest(forID: message.id, keepEntry: !terminal) else {
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
    
    private func onOutgoing<T: Blockchain>(
        _ response: BeaconResponse<T>,
        respondingTo request: BeaconRequest<T>,
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        do {
            switch response {
            case let .permission(response):
                guard let request: T.Request.Permission = {
                    switch request {
                    case let .permission(content):
                        return content
                    case .blockchain(_):
                        return nil
                    }
                }() else { throw Error.invalidRequest }
                onOutgoing(response, ofType: T.self, respondingTo: request, completion: completion)
            default:
                /* no action */
                completion(.success(()))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    private func onOutgoing<T: Blockchain>(
        _ response: T.Response.Permission,
        ofType type: T.Type,
        respondingTo request: T.Request.Permission,
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        do {
            guard let blockchain: T = blockchainRegistry.get() else {
                throw Beacon.Error.blockchainNotFound(type.identifier)
            }
            
            blockchain.creator.extractPermission(from: request, and: response) { result in
                guard let permission = result.get(ifFailure: completion) else { return }
                self.storageManager.add([permission], completion: completion)
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    private func savePendingRequest<T: Blockchain>(_ request: BeaconRequest<T>) {
        pendingRequests[request.id] = request
    }
    
    private func getPendingRequest<T: Blockchain>(forID id: String, keepEntry: Bool) -> BeaconRequest<T>? {
        if keepEntry {
            return pendingRequests[id] as? BeaconRequest<T>
        } else {
            return pendingRequests.removeValue(forKey: id) as? BeaconRequest<T>
        }
    }
    
    // MARK: Types
    
    enum Error: Swift.Error {
        case invalidRequest
    }
}

// MARK: Protocol

public protocol MessageControllerProtocol {
    func onIncoming<T: Blockchain>(
        _ message: VersionedBeaconMessage,
        with origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    )
    
    func onOutgoing<T: Blockchain>(
        _ message: BeaconMessage<T>,
        with beaconID: String,
        terminal: Bool,
        completion: @escaping (Result<(Beacon.Origin, VersionedBeaconMessage), Error>) -> ()
    )
    
    func onOutgoing(_ message: DisconnectBeaconMessage, with beaconID: String) throws -> (Beacon.Origin, VersionedBeaconMessage)
}
