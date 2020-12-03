//
//  Client.swift
//  BeaconSDK
//
//  Created by Julia Samol on 10.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    public class Client {
        
        public let name: String
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
        
        public static func create(with configuration: Configuration, completion: @escaping (Result<Client, Error>) -> ()) {
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
        
        public func connect(completion: @escaping (Result<(), Error>) -> ()) {
            connectionController.connect { result in
                completion(result.withBeaconError())
            }
        }
        
        public func listen(onRequest listener: @escaping (Result<Beacon.Request, Error>) -> ()) {
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
        
        public func respond(with response: Beacon.Response, completion: @escaping (Result<(), Error>) -> ()) {
            messageController.onOutgoing(.response(response), from: beaconID) { result in
                guard let (origin, versionedMessage) = result.get(ifFailure: completion) else { return }
                self.connectionController.send(BeaconConnectionMessage(origin: origin, content: versionedMessage)) { result in
                    completion(result.withBeaconError())
                }
            }
        }
        
        public func add(_ peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Error>) -> ()) {
            storage.add(peers) { result in
                guard result.isSuccess(else: completion) else { return }
                self.connectionController.onNew(peers) { result in
                    completion(result.withBeaconError())
                }
            }
        }
        
        public func remove(_ peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Error>) -> ()) {
            storage.remove(peers) { result in
                guard result.isSuccess(else: completion) else { return }
                self.connectionController.onDeleted(peers) { result in
                    completion(result.withBeaconError())
                }
            }
        }
        
        // MARK: Types
        
        public struct Configuration {
            public let name: String
            public let connections: [Beacon.Connection]
            
            public init(name: String, connections: [Beacon.Connection] = [.p2p()]) {
                self.name = name
                self.connections = connections
            }
        }
    }
}
