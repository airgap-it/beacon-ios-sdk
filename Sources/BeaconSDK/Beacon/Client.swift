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
        
        private let storage: ExtendedStorage
        private let connectionController: ConnectionControllerProtocol
        private let messageController: MessageControllerProtocol
        
        init(
            name: String,
            beaconID: String,
            storage: ExtendedStorage,
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
        
        public static func create(with configuration: Configuration, completion: @escaping (Result<Client, Swift.Error>) -> ()) {
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
                    completion(.failure(error))
                }
            }
        }
        
        // MARK: Connection
        
        public func connect(
            onRequest listener: @escaping (Result<Beacon.Request, Swift.Error>) -> (),
            completion: @escaping (Result<(), Swift.Error>) -> ()
        ) {
            connectionController.subscribe(onRequest: { [weak self] result in
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
            }, completion: completion) 
        }
        
        public func respond(with response: Beacon.Response, completion: @escaping (Result<(), Swift.Error>) -> ()) {
            messageController.onOutgoing(.response(response), from: beaconID) { result in
                guard let (origin, versionedMessage) = result.get(ifFailure: completion) else { return }
                self.connectionController.send(BeaconConnectionMessage(origin: origin, content: versionedMessage), completion: completion)
            }
        }
        
        public func add(_ peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Swift.Error>) -> ()) {
            storage.add(peers) { result in
                guard result.isSuccess(otherwise: completion) else { return }
                
                self.connectionController.on(new: peers, completion: completion)
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
