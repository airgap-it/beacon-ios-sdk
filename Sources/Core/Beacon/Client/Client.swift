//
//  Client.swift
//
//
//  Created by Julia Samol on 10.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    /// Base for Bacon clients.
    open class Client {
        
        /// The application details set by the user
        public let app: Application
        
        /// The name of the application set by the user
        public var name: String { app.name }
        
        /// A unique ID of this Beacon instance
        public let beaconID: String
        
        public let storageManager: StorageManager
        public let connectionController: ConnectionControllerProtocol
        public let messageController: MessageControllerProtocol
        public let crypto: Crypto
        public let serializer: Serializer
        
        public init(
            app: Application,
            beaconID: String,
            storageManager: StorageManager,
            connectionController: ConnectionControllerProtocol,
            messageController: MessageControllerProtocol,
            crypto: Crypto,
            serializer: Serializer
        ) {
            self.app = app
            self.beaconID = beaconID
            self.storageManager = storageManager
            self.connectionController = connectionController
            self.messageController = messageController
            self.crypto = crypto
            self.serializer = serializer
        }
        
        // MARK: Connection
        
        ///
        /// Starts Beacon and connects with known peers.
        ///
        /// - Parameter completion: The closure called after the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Beacon.Error` if it failed.
        ///
        public func connect(completion: @escaping (_ result: Result<(), Error>) -> ()) {
            connectionController.connect { result in
                completion(result.withBeaconError())
            }
        }
        
        ///
        /// Stops Beacon.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was succesful or `Beacon.Error` if it failed.
        ///
        public func disconnect(completion: @escaping (_ result: Result<(), Error>) -> ()) {
            connectionController.disconnect { result in
                completion(result.withBeaconError())
            }
        }
        
        ///
        /// Pauses Beacon. It can be later resumed with a call to `Beacon.Client#resume`.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was succesful or `Beacon.Error` if it failed.
        ///
        public func pause(completion: @escaping (_ result: Result<(), Error>) -> ()) {
            connectionController.pause { result in
                completion(result.withBeaconError())
            }
        }
        
        ///
        /// Resumes Beacon if paused.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was succesful or `Beacon.Error` if it failed.
        ///
        public func resume(completion: @escaping (_ result: Result<(), Error>) -> ()) {
            connectionController.resume { result in
                completion(result.withBeaconError())
            }
        }
        
        // MARK: Storage Management
        
        ///
        /// Adds new peers.
        ///
        /// The new peers will be persisted and subscribed.
        ///
        /// - Parameter peers: An array of new peers to which the client should connect.
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Beacon.Error` if it failed.
        ///
        public func add(_ peers: [Beacon.Peer], completion: @escaping (_ result: Result<(), Error>) -> ()) {
            storageManager.add(peers) { result in
                guard result.isSuccess(else: completion) else { return }
                self.connectionController.onNew(peers) { result in
                    completion(result.withBeaconError())
                }
            }
        }
        
        ///
        /// Returns an array of known peers.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: A result representing an array of known `Beacon.Peer` instances or `Beacon.Error` if the call failed.
        ///
        public func getPeers(completion: @escaping (_ result: Result<[Beacon.Peer], Error>) -> ()) {
            storageManager.getPeers { result in
                completion(result.withBeaconError())
            }
        }
        
        ///
        /// Removes known peers.
        ///
        /// The removed peers will be unsubscribed.
        ///
        /// - Parameter peers: An array of peers from which the client should disconnect.
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Beacon.Error` if it failed.
        ///
        public func remove(_ peers: [Beacon.Peer], completion: @escaping (Result<(), Error>) -> ()) {
            stopListening(to: peers) { result in
                peers.forEachAsync(body: { self.disconnect($0, completion: $1) }) { _ in
                    /* ignore disconnect results */
                    completion(result.withBeaconError())
                }
            }
        }
        
        ///
        /// Removes all known peers.
        ///
        /// The removed peers will be unsubscribed.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Beacon.Error` if it failed.
        ///
        public func removeAllPeers(completion: @escaping (_ result: Result<(), Error>) -> ()) {
            storageManager.getPeers { result in
                guard let peers = result.get(ifFailure: completion) else { return }
                self.remove(peers, completion: completion)
            }
        }
        
        public func removePeer(withPublicKey publicKey: String, completion: @escaping (Result<(), Error>) -> ()) {
            storageManager.findPeers(where: { $0.publicKey == publicKey }) { result in
                guard let peerOrNil = result.get(ifFailure: completion) else { return }
                guard let peer = peerOrNil else { return }
                
                self.remove([peer], completion: completion)
            }
        }
        
        ///
        /// Returns an array of granted permissions.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: A result representing an array of stored `Permission` instances or `Beacon.Error` if the call failed.
        ///
        public func getPermissions<T: PermissionProtocol>(completion: @escaping (_ result: Result<[T], Error>) -> ()) {
            storageManager.getPermissions { result in
                completion(result.withBeaconError())
            }
        }
        
        ///
        /// Returns permissions that have been granted for the specified `accountIdentifier`.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: A result representing the found `Permission` or `nil`, or `Beacon.Error` if the call failed..
        ///
        public func getPermissions<T: PermissionProtocol>(forAccountIdentifier accountIdentifier: String, completion: @escaping (_ result: Result<T?, Error>) -> ()) {
            storageManager.findPermissions(where: { $0.accountID == accountIdentifier }) { result in
                completion(result.withBeaconError())
            }
        }
        
        ///
        /// Removes permissions that have been granted for the specified `accountIdentifier`.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Beacon.Error` if it failed.
        ///
        public func removePermissions<T: PermissionProtocol>(
            ofType type: T.Type,
            forAccountIdentifier accountIdentifier: String,
            completion: @escaping (_ result: Result<(), Error>) -> ()
        ) {
            storageManager.removePermissions(where: { (permission: T) in permission.accountID == accountIdentifier }) { result in
                completion(result.withBeaconError())
            }
        }
        
        ///
        /// Removes permissions that have been granted for the specified `accountIdentifier`.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Beacon.Error` if it failed.
        ///
        public func removePermissions(forAccountIdentifier accountIdentifier: String, completion: @escaping (_ result: Result<(), Error>) -> ()) {
            storageManager.removeAllPermissions(where: { $0.accountID == accountIdentifier }) { result in
                completion(result.withBeaconError())
            }
        }
        
        ///
        /// Removes the specified permissions.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Beacon.Error` if it failed.
        ///
        public func remove<T: PermissionProtocol>(_ permissions: [T], completion: @escaping (_ result: Result<(), Error>) -> ()) {
            storageManager.remove(permissions) { result in
                completion(result.withBeaconError())
            }
        }
        
        ///
        /// Removes all granted permissions.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Beacon.Error` if it failed.
        ///
        public func removeAllPermissions<T: PermissionProtocol>(ofType type: T.Type, completion: @escaping (_ result: Result<(), Error>) -> ()) {
            storageManager.removePermissions(ofType: type) { result in
                completion(result.withBeaconError())
            }
        }
        
        ///
        /// Removes all granted permissions.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Beacon.Error` if it failed.
        ///
        public func removeAllPermissions(completion: @escaping (_ result: Result<(), Error>) -> ()) {
            storageManager.removeAllPermissions { result in
                completion(result.withBeaconError())
            }
        }
        
        // MARK: Pairing
        
        public func serializePairingData(_ pairingMessage: BeaconPairingMessage) throws -> String {
            try serializer.serialize(message: pairingMessage)
        }
        
        public func deserializePairingData(_ serialized: String) throws -> BeaconPairingMessage {
            try deserializePairingData(serialized, ofType: BeaconPairingMessage.self)
        }
        
        public func deserializePairingData<T : BeaconPairingMessageProtocol & Decodable>(_ serialized: String, ofType type: T.Type) throws -> T {
            try serializer.deserialize(message: serialized, to: type)
        }
        
        // MARK: Private
        
        private func disconnect(_ peer: Beacon.Peer, completion: @escaping (Result<(), Error>) -> ()) {
            do {
                let origin = Beacon.Origin(kind: peer.kind, id: peer.publicKey)
                let message: BeaconMessage<AnyBlockchain> = .disconnect(
                    .init(
                        id: try crypto.guid(),
                        senderID: beaconID,
                        version: peer.version,
                        origin: origin
                    )
                )
                send(message, terminalMessage: true, completion: completion)
            } catch {
                completion(.failure(Error(error)))
            }
        }
        
        public func send<B: Blockchain>(_ message: BeaconMessage<B>, terminalMessage: Bool, completion: @escaping (Result<(), Error>) -> ()) {
            messageController.onOutgoing(message, with: beaconID, terminal: terminalMessage) { result in
                guard let (origin, versionedMessage) = result.get(ifFailure: completion) else { return }
                self.send(BeaconConnectionMessage(origin: origin, content: versionedMessage), completion: completion)
            }
        }
        
        private func send<B: Blockchain>(_ message: BeaconConnectionMessage<B>, completion: @escaping (Result<(), Error>) -> ()) {
            connectionController.send(message) { result in
                completion(result.withBeaconError())
            }
        }
        
        private func stopListening(to peers: [Beacon.Peer], completion: @escaping (Result<(), Error>) -> ()) {
            storageManager.remove(peers) { result in
                guard result.isSuccess(else: completion) else { return }
                self.connectionController.onRemoved(peers) { result in
                    completion(result.withBeaconError())
                }
            }
        }
    }
}
