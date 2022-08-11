//
//  WalletClient.swift
//  
//
//  Created by Julia Samol on 21.09.21.
//

import Foundation
import BeaconCore

extension Beacon {
    
    /// Asynchronous client that comunicates with dApps.
    public class WalletClient: Client, BeaconConsumer {
        
        // MARK: Initialization
        
        ///
        /// Asynchronously creates a new instance of `Beacon.WalletClient`.
        ///
        /// - Parameter configuration: A group of required and optional values used to create the client.
        /// - Parameter completion: The closure invoked when the instance has been created.
        /// - Parameter result: The created instance if the call was succesful or `Beacon.Error` otherwise.
        ///
        public static func create(with configuration: Configuration, completion: @escaping (_ result: Result<WalletClient, Error>) -> ()) {
            let storage = configuration.storage ?? UserDefaultsStorage()
            let secureStorage = configuration.secureStorage ?? UserDefaultsSecureStorage()
            
            Beacon.initialize(
                appName: configuration.name,
                appIcon: configuration.iconURL,
                appURL: configuration.appURL,
                blockchainFactories: configuration.blockchains,
                storage: storage,
                secureStorage: secureStorage
            ) { result in
                guard let beacon = result.get(ifFailure: completion) else { return }
                
                do {
                    let client = WalletClient(
                        app: beacon.app,
                        beaconID: beacon.beaconID,
                        storageManager: beacon.dependencyRegistry.storageManager,
                        connectionController: try beacon.dependencyRegistry.connectionController(configuredWith: configuration.connections),
                        messageController: beacon.dependencyRegistry.messageController,
                        crypto: beacon.dependencyRegistry.crypto,
                        serializer: beacon.dependencyRegistry.serializer
                    )
                    
                    completion(.success(client))
                } catch {
                    completion(.failure(Error(error)))
                }
            }
        }
        
        // MARK: Pairing
        
        public func pair(with pairingRequest: BeaconPairingRequest, completion: @escaping (Result<BeaconPairingResponse, Error>) -> ()) {
            connectionController.pair(with: pairingRequest) { result in
                completion(result.withBeaconError())
            }
        }
        
        public func pair(with pairingRequest: String, completion: @escaping (Result<BeaconPairingResponse, Error>) -> ()) {
            do {
                let pairingRequest = try deserializePairingData(pairingRequest, ofType: BeaconPairingRequest.self)
                pair(with: pairingRequest, completion: completion)
            } catch {
                completion(.failure(Error(error)))
            }
        }
        
        // MARK: Connection
        
        ///
        /// Listens for incoming messages.
        ///
        /// - Parameter listener: The closure called whenever a new request arrives.
        /// - Parameter result: A result representing the incoming request, either `BeaconRequest<T>` or `Beacon.Error` if message processing failed.
        ///
        public func listen<B: Blockchain>(onRequest listener: @escaping (_ result: Result<BeaconRequest<B>, Error>) -> ()) {
            connectionController.listen { [weak self] (result: Result<BeaconConnectionMessage<B>, Swift.Error>) in
                guard let connectionMessage = result.get(ifFailure: listener) else { return }
                self?.messageController.onIncoming(connectionMessage.content, with: connectionMessage.origin) { (result: Result<BeaconMessage<B>, Swift.Error>) in
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
        public func respond<B: Blockchain>(with response: BeaconResponse<B>, completion: @escaping (_ result: Result<(), Error>) -> ()) {
            send(.response(response), terminalMessage: true, completion: completion)
        }
        
        ///
        /// Returns an array of stored app metadata.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: A result representing an array of stored `Beacon.AppMetadata` instances or `Beacon.Error` if the call failed.
        ///
        public func getAppMetadata<T: AppMetadataProtocol>(completion: @escaping (_ result: Result<[T], Error>) -> ()) {
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
        public func getAppMetadata<T: AppMetadataProtocol>(forSenderID senderID: String, completion: @escaping (_ result: Result<T?, Error>) -> ()) {
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
        public func removeAppMetadata<T: AppMetadataProtocol>(
            ofType type: T.Type,
            forSenderID senderID: String,
            completion: @escaping (_ result: Result<(), Error>) -> ()
        ) {
            storageManager.removeAppMetadata(where: { (appMetadata: T) in appMetadata.senderID == senderID }) { result in
                completion(result.withBeaconError())
            }
        }
        
        ///
        /// Removes the specified app metadata.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Beacon.Error` if it failed.
        ///
        public func remove<T: AppMetadataProtocol>(_ appMetadata: [T], completion: @escaping (_ result: Result<(), Error>) -> ()) {
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
        public func removeAllMetadata<T: AppMetadataProtocol>(ofType type: T.Type, completion: @escaping (_ result: Result<(), Error>) -> ()) {
            storageManager.removeAppMetadata(ofType: type) { result in
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
            storageManager.removeAllAppMetadata { result in
                completion(result.withBeaconError())
            }
        }
        
        private func acknowledge<B: Blockchain>(_ request: BeaconRequest<B>, completion: @escaping (Result<(), Error>) -> ()) {
            let message = AcknowledgeBeaconResponse(from: request)
            send(BeaconMessage<B>.response(.acknowledge(message)), terminalMessage: false, completion: completion)
        }
     
        // MARK: Types
        
        /// A group of the `Beacon.WalletClient` configuration values.
        public struct Configuration {
            
            /// The name of the application.
            public let name: String
            
            /// A URL to the application's webpage.
            public let appURL: String?
            
            /// A URL to the application's icon.
            public let iconURL: String?
            
            /// Blockchains that will be supported by the configured client.
            public let blockchains: [BlockchainFactory]
            
            /// Connection types that will be supported by the configured client.
            public let connections: [Beacon.Connection]
            
            /// An optional external implementation of `Storage`.
            public let storage: Storage?
            
            /// An optional external implementation of `SecureStorage`.
            public let secureStorage: SecureStorage?
            
            ///
            /// Creates a new configuration from the given application name and supported connections.
            ///
            /// - Parameter name: The name of the application.
            /// - Parameter appURL: A URL to the application's webpage.
            /// - Parameter iconURL: A URL to the application's icon.
            /// - Parameter blockchains: Supported blockchains.
            /// - Parameter connections: Supported connection types.
            /// - Parameter storage: An optional storage to preserve Beacon state, if not provided, an internal implementation will be used.
            /// - Parameter secureStorage: An optional storage to preserve sensitive Beacon state,  if not provided, an internal implementation will be used.
            ///
            public init(
                name: String,
                appURL: String? = nil,
                iconURL: String? = nil,
                blockchains: [BlockchainFactory],
                connections: [Beacon.Connection],
                storage: Storage? = nil,
                secureStorage: SecureStorage? = nil
            ) {
                self.name = name
                self.appURL = appURL
                self.iconURL = iconURL
                self.blockchains = blockchains
                self.connections = connections
                self.storage = storage
                self.secureStorage = secureStorage
            }
        }
    }
}
