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
        
        private let storage: StorageManager
        private let connectionController: ConnectionControllerProtocol
        private let messageController: MessageControllerProtocol
        
        init(
            name: String,
            beaconID: String,
            storage: StorageManager,
            connectionController: ConnectionControllerProtocol,
            messageController: MessageControllerProtocol
        ) {
            self.name = name
            self.beaconID = beaconID
            self.storage = storage
            self.connectionController = connectionController
            self.messageController = messageController
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
            
            Beacon.initialize(appName: configuration.name, storage: storage) { result in
                guard let beacon = result.get(ifFailure: completion) else { return }
                
                do {
                    let beaconClient = Client(
                        name: beacon.appName,
                        beaconID: beacon.beaconID,
                        storage: beacon.dependencyRegistry.storage,
                        connectionController: try beacon.dependencyRegistry.connectionController(configuredWith: configuration.connections),
                        messageController: beacon.dependencyRegistry.messageController
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
            messageController.onOutgoing(.response(response), from: beaconID) { result in
                guard let (origin, versionedMessage) = result.get(ifFailure: completion) else { return }
                self.connectionController.send(BeaconConnectionMessage(origin: origin, content: versionedMessage)) { result in
                    completion(result.withBeaconError())
                }
            }
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
        public func add(_ peers: [Beacon.PeerInfo], completion: @escaping (_ result: Result<(), Error>) -> ()) {
            storage.add(peers) { result in
                guard result.isSuccess(else: completion) else { return }
                self.connectionController.onNew(peers) { result in
                    completion(result.withBeaconError())
                }
            }
        }
        
        /// Removes known peers.
        ///
        /// The removed peers will be unsubscribed.
        ///
        /// - Parameter peers: An array of peers from which the client should disconnect.
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Beacon.Error` if it failed.
        ///
        public func remove(_ peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Error>) -> ()) {
            storage.remove(peers) { result in
                guard result.isSuccess(else: completion) else { return }
                self.connectionController.onDeleted(peers) { result in
                    completion(result.withBeaconError())
                }
            }
        }
        
        // MARK: Types
        
        /// A group of the `Beacon.Client` configuration values.
        public struct Configuration {
            
            /// The name of the application.
            public let name: String
            
            /// Connection types that will be supported by the configured client.
            public let connections: [Beacon.Connection]
            
            ///
            /// Creates a new configuration from the given application name and supported connections.
            ///
            /// - Parameter name: The name of the application.
            /// - Parameter connections: Supported connection types, P2P by default.
            ///
            public init(name: String, connections: [Beacon.Connection] = [.p2p()]) {
                self.name = name
                self.connections = connections
            }
        }
    }
}
