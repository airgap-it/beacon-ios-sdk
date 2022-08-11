//
//  File.swift
//  
//
//  Created by Julia Samol on 10.08.22.
//

import Foundation
import BeaconCore

extension Beacon {
    
    public class DAppClient: Client, BeaconProducer {
        private let accountController: AccountControllerProtocol
        
        public init(
            app: Beacon.Application,
            beaconID: String,
            storageManager: StorageManager,
            connectionController: ConnectionControllerProtocol,
            messageController: MessageControllerProtocol,
            accountController: AccountControllerProtocol,
            crypto: Crypto,
            serializer: Serializer
        ) {
            self.accountController = accountController
            super.init(
                app: app,
                beaconID: beaconID,
                storageManager: storageManager,
                connectionController: connectionController,
                messageController: messageController,
                crypto: crypto,
                serializer: serializer
            )
        }
        
        // MARK: Initialization
        
        public static func create(with configuration: Configuration, completion: @escaping (_ result: Result<DAppClient, Error>) -> ()) {
            let storage = configuration.storage ?? UserDefaultsDAppClientStorage(storage: UserDefaultsStorage())
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
                let extendedDependencyRegistry = beacon.dependencyRegistry.extend()
                
                if extendedDependencyRegistry.storageManager.dAppClientPlugin == nil {
                    extendedDependencyRegistry.storageManager.addPlugins([storage.extend()])
                }
                
                do {
                    let client = DAppClient(
                        app: beacon.app,
                        beaconID: beacon.beaconID,
                        storageManager: extendedDependencyRegistry.storageManager,
                        connectionController: try extendedDependencyRegistry.connectionController(configuredWith: configuration.connections),
                        messageController: extendedDependencyRegistry.messageController,
                        accountController: extendedDependencyRegistry.accountController,
                        crypto: extendedDependencyRegistry.crypto,
                        serializer: extendedDependencyRegistry.serializer
                    )
                    
                    completion(.success(client))
                } catch {
                    completion(.failure(Error(error)))
                }
            }
        }
        
        // MARK: Pairing
        
        public func pair(using connectionKind: Beacon.Connection.Kind = .p2p, onMessage listener: @escaping (Result<BeaconPairingMessage, Beacon.Error>) -> ()) {
            connectionController.pair(using: connectionKind) { pairResult in
                do {
                    let pairingMessage = try pairResult.get()
                    switch pairingMessage {
                    case let .request(pairingRequest):
                        /* no action */
                        listener(.success(.request(pairingRequest)))
                    case let .response(pairingResponse):
                        self.accountController.onPairingResponse(pairingResponse) { handleResult in
                            listener(handleResult.map({ .response(pairingResponse) }).withBeaconError())
                        }
                    }
                } catch {
                    listener(.failure(Error(error)))
                }
            }
        }
        
        // MARK: Connection
        
        ///
        /// Listens for incoming messages.
        ///
        /// - Parameter listener: The closure called whenever a new request arrives.
        /// - Parameter result: A result representing the incoming request, either `BeaconResponse<T>` or `Beacon.Error` if message processing failed.
        ///
        public func listen<B: Blockchain>(onResponse listener: @escaping (_ result: Result<BeaconResponse<B>, Error>) -> ()) {
            connectionController.listen { [weak self] (result: Result<BeaconConnectionMessage<B>, Swift.Error>) in
                guard let connectionMessage = result.get(ifFailure: listener) else { return }
                self?.messageController.onIncoming(connectionMessage.content, with: connectionMessage.origin) { (result: Result<BeaconMessage<B>, Swift.Error>) in
                    guard let beaconMessage = result.get(ifFailure: listener) else { return }
                    switch beaconMessage {
                    case let .response(response):
                        listener(.success(response))
                    case let .disconnect(disconnect):
                        self?.removePeer(withPublicKey: disconnect.origin.id) { _ in }
                    default:
                        /* ignore other messages */
                        break
                    }
                }
            }
        }
        
        public func request<B: Blockchain>(with request: BeaconRequest<B>, completion: @escaping (_ result: Result<(), Beacon.Error>) -> ()) {
            
        }
        
        // MARK: Types
        
        /// A group of the `Beacon.DAppClient` configuration values.
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
            
            /// An optional external implementation of `DAppClientStorage`.
            public let storage: DAppClientStorage?
            
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
                storage: DAppClientStorage? = nil,
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
