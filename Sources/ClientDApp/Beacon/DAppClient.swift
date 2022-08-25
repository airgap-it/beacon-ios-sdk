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
        private let identifierCreator: IdentifierCreatorProtocol
        
        private var _senderID: String? = nil
        public func senderID() throws -> String {
            guard let senderID = _senderID else {
                let senderID = try self.identifierCreator.senderID(from: HexString(from: app.keyPair.publicKey))
                self._senderID = senderID
                
                return senderID
            }
            
            return senderID
        }
        
        public init(
            app: Application,
            beaconID: String,
            storageManager: StorageManager,
            connectionController: ConnectionControllerProtocol,
            messageController: MessageControllerProtocol,
            accountController: AccountControllerProtocol,
            crypto: Crypto,
            serializer: Serializer,
            identifierCreator: IdentifierCreatorProtocol
        ) {
            self.accountController = accountController
            self.identifierCreator = identifierCreator
            
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
                guard let beacon = result.get(ifFailureWithBeaconError: completion) else { return }
                let extendedDependencyRegistry = beacon.dependencyRegistry.extend()
                
                do {
                    let client = try extendedDependencyRegistry.dAppClient(storagePlugin: storage, connections: configuration.connections)
                    completion(.success(client))
                } catch {
                    completion(.failure(Error(error)))
                }
            }
        }
        
        // MARK: Pairing
        
        public func pair(using connectionKind: Connection.Kind = .p2p, onMessage listener: @escaping (Result<BeaconPairingMessage, Error>) -> ()) {
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
        
        // MARK: Accounts
        
        public func getActiveAccount(completion: @escaping (Result<Account?, Error>) -> ()) {
            accountController.getActiveAccount { result in
                completion(result.map({ $0?.account }).withBeaconError())
            }
        }
        
        public func clearActiveAccount(completion: @escaping (Result<(), Error>) -> ()) {
            accountController.clearActiveAccount { result in
                completion(result.withBeaconError())
            }
        }
        
        public func reset(completion: @escaping (Result<(), Error>) -> ()) {
            accountController.clearAll { result in
                completion(result.withBeaconError())
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
            connectionController.listen { [weak self] (result: Result<BeaconIncomingConnectionMessage<B>, Swift.Error>) in
                guard let connectionMessage = result.get(ifFailureWithBeaconError: listener) else { return }
                guard let strongSelf = self else { return }
                
                strongSelf.messageController.onIncoming(
                    connectionMessage.content,
                    withOrigin: connectionMessage.origin,
                    andDestination: strongSelf.ownOrigin(from: connectionMessage.origin)
                ) { (result: Result<BeaconMessage<B>, Swift.Error>) in
                    guard let beaconMessage = result.get(ifFailureWithBeaconError: listener) else { return }
                    switch beaconMessage {
                    case let .response(response):
                        listener(.success(response))
                        strongSelf.processResponse(response, withOrigin: connectionMessage.origin) { processResult in
                            if case let .failure(error) = processResult {
                                listener(.failure(Error(error)))
                            }
                        }
                    case let .disconnect(disconnect):
                        strongSelf.removePeer(withPublicKey: disconnect.origin.id) { _ in }
                    default:
                        /* ignore other messages */
                        break
                    }
                }
            }
        }
        
        public func request<B: Blockchain>(with request: BeaconRequest<B>, completion: @escaping (_ result: Result<(), Error>) -> ()) {
            send(.request(request), terminalMessage: false, completion: completion)
        }
        
        // MARK: Utils
        
        public func prepareRequest(for connectionKind: Connection.Kind, completion: @escaping (Result<BeaconRequestMetadata, Error>) -> ()) {
            accountController.getActivePeer { peerResult in
                guard let activePeerOrNil = peerResult.get(ifFailureWithBeaconError: completion) else { return }
                guard let activePeer = activePeerOrNil else {
                    completion(.failure(Error.missingPairedPeer))
                    return
                }
                
                self.accountController.getActiveAccount { accountResult in
                    guard let activeAccount = accountResult.get(ifFailureWithBeaconError: completion) else { return }
                    
                    do {
                        completion(.success(.init(
                            id: try self.crypto.guid(),
                            version: Beacon.Configuration.beaconVersion,
                            senderID: try self.senderID(),
                            origin: .init(kind: connectionKind, id: HexString(from: self.app.keyPair.publicKey).asString()),
                            destination: activePeer.toConnectionID(),
                            account: activeAccount?.account
                        )))
                    } catch {
                        completion(.failure(Error(error)))
                    }
                }
            }
        }
        
        private func processResponse<B: Blockchain>(
            _ response: BeaconResponse<B>,
            withOrigin origin: Connection.ID,
            completion: @escaping (Result<(), Error>) -> ()
        ) {
            switch response {
            case let .permission(permission):
                accountController.onPermissionResponse(permission, ofType: B.self, origin: origin) { result in
                    completion(result.withBeaconError())
                }
            default:
                /* no action*/
                completion(.success(()))
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
