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
        
        public static func create(with configuration: Configuration, completion: @escaping (_ result: Result<DAppClient, Error>) -> ()) {
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
                    let client = DAppClient(
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
        
        public func request<B: Blockchain>(with request: BeaconRequest<B>, completion: @escaping (_ result: Result<(), Beacon.Error>) -> ()) {
            
        }
        
        public func pair(using connectionKind: Beacon.Connection.Kind, onMessage listener: @escaping (Result<BeaconPairingMessage, Beacon.Error>) -> ()) {
            connectionController.pair(using: connectionKind) { result in
                listener(result.withBeaconError())
            }
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
