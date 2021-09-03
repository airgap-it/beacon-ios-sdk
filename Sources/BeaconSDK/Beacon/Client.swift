//
//  Client.swift
//  BeaconSDK
//
//  Created by Julia Samol on 10.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    /// Asynchronous client that comunicates with dApps.
    public class Client {
        
        /// The name of the application set by the user
        public let name: String
        
        /// A unique ID of this Beacon instance
        public let beaconID: String
        
        private let storageManager: StorageManager
        private let connectionController: ConnectionControllerProtocol
        private let messageController: MessageControllerProtocol
        private let crypto: Crypto
        
        init(
            name: String,
            beaconID: String,
            storageManager: StorageManager,
            connectionController: ConnectionControllerProtocol,
            messageController: MessageControllerProtocol,
            crypto: Crypto
        ) {
            self.name = name
            self.beaconID = beaconID
            self.storageManager = storageManager
            self.connectionController = connectionController
            self.messageController = messageController
            self.crypto = crypto
        }
        
        // MARK: Initialization
        
        ///
        /// Asynchronously creates a new instance of `Beacon.Client`.
        ///
        /// - Parameter configuration: A group of required and optional values used to create the client.
        /// - Parameter completion: The closure invoked when the instance has been created.
        /// - Parameter result: The created instance if the call was succesful or `Beacon.Error` otherwise.
        ///
        public static func create(with configuration: Configuration, completion: @escaping (_ result: Result<Client, Error>) -> ()) {
            let storage = UserDefaultsStorage()
            let secureStorage = UserDefaultsSecureStorage()
            
            Beacon.initialize(
                appName: configuration.name,
                appIcon: configuration.iconURL,
                appURL: configuration.appURL,
                storage: storage,
                secureStorage: secureStorage
            ) { result in
                guard let beacon = result.get(ifFailure: completion) else { return }
                
                do {
                    let beaconClient = Client(
                        name: beacon.app.name,
                        beaconID: beacon.beaconID,
                        storageManager: beacon.dependencyRegistry.storageManager,
                        connectionController: try beacon.dependencyRegistry.connectionController(configuredWith: configuration.connections),
                        messageController: beacon.dependencyRegistry.messageController,
                        crypto: beacon.dependencyRegistry.crypto
                    )
                    
                    completion(.success(beaconClient))
                } catch {
                    completion(.failure(Error(error)))
                }
            }
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
        /// Listens for incoming messages.
        ///
        /// - Parameter listener: The closure called whenever a new request arrives.
        /// - Parameter result: A result representing the incoming request, either `Beacon.Request` or `Beacon.Error` if message processing failed.
        ///
        public func listen(onRequest listener: @escaping (_ result: Result<Beacon.Request, Error>) -> ()) {
            connectionController.listen { [weak self] result in
                guard let versionedMessage = result.get(ifFailure: listener) else { return }
                self?.messageController.onIncoming(versionedMessage.content, with: versionedMessage.origin) { result in
                    guard let beaconMessage = result.get(ifFailure: listener) else { return }
                    switch beaconMessage {
                    case let .request(request):
                        listener(.success(request))
                        self?.acknowledge(request) { _ in }
                    case let .disconnect(disconnect):
                        self?.removePeer(withPublicKey: disconnect.origin.id) { _ in }
                    default:
                        /* ignore other messages */
                        break
                    }
                }
            }
        }
        
        ///
        /// Replies to a previously received request.
        ///
        /// - Parameter response: The message to be sent in reply.
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Beacon.Error` if it failed.
        ///
        public func respond(with response: Beacon.Response, completion: @escaping (_ result: Result<(), Error>) -> ()) {
            send(.response(response), terminalMessage: true, completion: completion)
        }
        
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
        
        ///
        /// Returns an array of stored app metadata.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: A result representing an array of stored `Beacon.AppMetadata` instances or `Beacon.Error` if the call failed.
        ///
        public func getAppMetadata(completion: @escaping (_ result: Result<[Beacon.AppMetadata], Error>) -> ()) {
            storageManager.getAppMetadata { result in
                completion(result.withBeaconError())
            }
        }
        
        ///
        /// Returns the first app metadata that matches the specified `senderID`
        /// or `nil` if no such app metadata was found.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: A result representing the found `Beacon.AppMetadata` or `nil`, or `Beacon.Error` if the call failed..
        ///
        public func getAppMetadata(forSenderID senderID: String, completion: @escaping (_ result: Result<Beacon.AppMetadata?, Error>) -> ()) {
            storageManager.findAppMetadata(where: { $0.senderID == senderID }) { result in
                completion(result.withBeaconError())
            }
        }
        
        ///
        /// Removes app metadata that matches the specified `senderID`.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Beacon.Error` if it failed.
        ///
        public func removeAppMetadata(forSenderID senderID: String, completion: @escaping (_ result: Result<(), Error>) -> ()) {
            storageManager.removeAppMetadata(where: { $0.senderID == senderID }) { result in
                completion(result.withBeaconError())
            }
        }
        
        ///
        /// Removes the specified app metadata.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Beacon.Error` if it failed.
        ///
        public func remove(_ appMetadata: [Beacon.AppMetadata], completion: @escaping (_ result: Result<(), Error>) -> ()) {
            storageManager.remove(appMetadata) { result in
                completion(result.withBeaconError())
            }
        }
        
        ///
        /// Removes all stored app metadata.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Beacon.Error` if it failed.
        ///
        public func removeAllMetadata(completion: @escaping (_ result: Result<(), Error>) -> ()) {
            storageManager.removeAppMetadata { result in
                completion(result.withBeaconError())
            }
        }
        
        ///
        /// Returns an array of granted permissions.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: A result representing an array of stored`Beacon.Permission` instances or `Beacon.Error` if the call failed.
        ///
        public func getPermissions(completion: @escaping (_ result: Result<[Beacon.Permission], Error>) -> ()) {
            storageManager.getPermissions { result in
                completion(result.withBeaconError())
            }
        }
        
        ///
        /// Returns permissions that have been granted for the specified `accountIdentifier`.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: A result representing the found `Beacon.Permission` or `nil`, or `Beacon.Error` if the call failed..
        ///
        public func getPermissions(forAccountIdentifier accountIdentifier: String, completion: @escaping (_ result: Result<Beacon.Permission?, Error>) -> ()) {
            storageManager.findPermissions(where: { $0.accountIdentifier == accountIdentifier }) { result in
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
            storageManager.removePermissions(where: { $0.accountIdentifier == accountIdentifier }) { result in
                completion(result.withBeaconError())
            }
        }
        
        ///
        /// Removes the specified permissions.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Beacon.Error` if it failed.
        ///
        public func remove(_ permissions: [Beacon.Permission], completion: @escaping (_ result: Result<(), Error>) -> ()) {
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
        public func removeAllPermissions(completion: @escaping (_ result: Result<(), Error>) -> ()) {
            storageManager.removePermissions { result in
                completion(result.withBeaconError())
            }
        }
        
        private func removePeer(withPublicKey publicKey: String, completion: @escaping (Result<(), Error>) -> ()) {
            storageManager.findPeers(where: { $0.common.publicKey == publicKey }) { result in
                guard let peerOrNil = result.get(ifFailure: completion) else { return }
                guard let peer = peerOrNil else { return }
                
                self.stopListening(to: [peer], completion: completion)
            }
        }
        
        private func acknowledge(_ request: Beacon.Request, completion: @escaping (Result<(), Error>) -> ()) {
            let message = Response.Acknowledge(from: request)
            send(.response(.acknowledge(message)), terminalMessage: false, completion: completion)
        }
        
        private func disconnect(_ peer: Beacon.Peer, completion: @escaping (Result<(), Error>) -> ()) {
            do {
                let origin = Beacon.Origin(kind: peer.common.kind, id: peer.common.publicKey)
                let message = Message.Disconnect(id: try crypto.guid(), senderID: beaconID, version: peer.common.version, origin: origin)
                send(.disconnect(message), terminalMessage: true, completion: completion)
            } catch {
                completion(.failure(Error(error)))
            }
        }
        
        private func send(_ message: Beacon.Message, terminalMessage: Bool, completion: @escaping (_ result: Result<(), Error>) -> ()) {
            messageController.onOutgoing(message, with: beaconID, terminal: terminalMessage) { result in
                guard let (origin, versionedMessage) = result.get(ifFailure: completion) else { return }
                self.connectionController.send(BeaconConnectionMessage(origin: origin, content: versionedMessage)) { result in
                    completion(result.withBeaconError())
                }
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
        
        // MARK: Types
        
        /// A group of the `Beacon.Client` configuration values.
        public struct Configuration {
            
            /// The name of the application.
            public let name: String
            
            /// A URL to the application's webpage.
            public let appURL: String?
            
            /// A URL to the application's icon.
            public let iconURL: String?
            
            /// Connection types that will be supported by the configured client.
            public let connections: [Beacon.Connection]
            
            ///
            /// Creates a new configuration from the given application name and supported connections.
            ///
            /// - Parameter name: The name of the application.
            /// - Parameter connections: Supported connection types, P2P by default.
            ///
            public init(name: String, appURL: String? = nil, iconURL: String? = nil, connections: [Beacon.Connection] = [.p2p()]) {
                self.name = name
                self.appURL = appURL
                self.iconURL = iconURL
                self.connections = connections
            }
        }
    }
}
