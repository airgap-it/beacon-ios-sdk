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
    
    private var outgoingRequests: [String: BeaconRequestProtocol] = [:]
    private var incomingRequests: [String: BeaconRequestProtocol] = [:]
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
            
            self.onIncoming(beaconMessage, withOrigin: origin) { result in
                guard result.isSuccess(else: completion) else { return }
                completion(.success(beaconMessage))
            }
        }
    }
    
    private func onIncoming<B: Blockchain>(_ message: BeaconMessage<B>, withOrigin origin: Beacon.Connection.ID, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        switch message {
        case let .request(request):
            self.queue.async {
                self.saveIncomingRequest(request)
                self.onIncoming(request, completion: completion)
            }
        case let .response(response):
            queue.async {
                guard let request: BeaconRequest<B> = self.getOutgoingRequest(forID: response.id, response: response) else {
                    completion(.failure(Beacon.Error.noPendingRequest(id: message.id)))
                    return
                }
                
                self.onIncoming(response, respondingTo: request, withOrigin: origin, completion: completion)
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
    
    private func onIncoming<B: Blockchain>(
        _ response: BeaconResponse<B>,
        respondingTo request: BeaconRequest<B>,
        withOrigin origin: Beacon.Connection.ID,
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        do {
            switch response {
            case let .permission(response):
                guard case let .permission(request) = request else { throw Error.invalidRequest }
                onIncoming(response, ofType: B.self, respondingTo: request, withOrigin: origin, completion: completion)
            default:
                /* no action */
                completion(.success(()))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    private func onIncoming<B: Blockchain>(
        _ response: B.Response.Permission,
        ofType type: B.Type,
        respondingTo request: B.Request.Permission,
        withOrigin origin: Beacon.Connection.ID,
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        do {
            guard let blockchain: B = blockchainRegistry.get() else {
                throw Beacon.Error.blockchainNotFound(type.identifier)
            }
            
            blockchain.creator.extractIncomingPermission(from: request, and: response, withOrigin: origin) { result in
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
        case let .request(request):
            self.queue.async {
                self.saveOutgoingRequest(request, terminal: terminal)
                self.onOutgoing(request, completion: completion)
            }
        case let .response(response):
            queue.async {
                guard let request: BeaconRequest<B> = self.getIncomingRequest(forID: message.id, keepEntry: !terminal) else {
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
    
    private func onOutgoing<B: Blockchain>(_ request: BeaconRequest<B>, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        /* no action */
        completion(.success(()))
    }
    
    private func onOutgoing<B: Blockchain>(
        _ response: BeaconResponse<B>,
        respondingTo request: BeaconRequest<B>,
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        do {
            switch response {
            case let .permission(response):
                guard case let .permission(request) = request else { throw Error.invalidRequest }
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
    
    private func saveOutgoingRequest<B: Blockchain>(_ request: BeaconRequest<B>, terminal: Bool) {
        if !terminal {
            outgoingRequests[request.id] = request
        }
    }
    
    private func saveIncomingRequest<B: Blockchain>(_ request: BeaconRequest<B>) {
        incomingRequests[request.id] = request
    }
    
    private func getOutgoingRequest<B: Blockchain>(forID id: String, response: BeaconResponse<B>) -> BeaconRequest<B>? {
        let keepEntry: Bool = {
            switch response {
            case .acknowledge(_):
                return true
            default:
                return false
            }
        }()
        
        if keepEntry {
            return outgoingRequests[id] as? BeaconRequest<B>
        } else {
            return outgoingRequests.removeValue(forKey: id) as? BeaconRequest<B>
        }
    }
    
    private func getIncomingRequest<B: Blockchain>(forID id: String, keepEntry: Bool) -> BeaconRequest<B>? {
        if keepEntry {
            return incomingRequests[id] as? BeaconRequest<B>
        } else {
            return incomingRequests.removeValue(forKey: id) as? BeaconRequest<B>
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
