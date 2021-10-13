//
//  P2PMatrixDependencyRegistry.swift
//  
//
//  Created by Julia Samol on 27.09.21.
//

import Foundation
import BeaconCore

class P2PMatrixDependencyRegistry: ExtendedDependencyRegistry {
    private let dependencyRegistry: DependencyRegistry
    
    init(dependencyRegistry: DependencyRegistry) {
        self.dependencyRegistry = dependencyRegistry
    }
    
    // MARK: P2P
    
    func p2pMatrixCommunicator() throws -> Transport.P2P.Matrix.Communicator {
        try weakP2PMatrixCommunicator.value()
    }
    
    private lazy var weakP2PMatrixCommunicator: ThrowingLazyWeakReference<Transport.P2P.Matrix.Communicator> = ThrowingLazyWeakReference { [unowned self] in
        guard let beacon = Beacon.shared else {
            throw Beacon.Error.unknown
        }
        
        return Transport.P2P.Matrix.Communicator(app: beacon.app, crypto: self.crypto)
    }
    
    func p2pMatrixSecurity() throws -> Transport.P2P.Matrix.Security {
        try weakP2PMatrixSecurity.value()
    }
    
    private lazy var weakP2PMatrixSecurity: ThrowingLazyWeakReference<Transport.P2P.Matrix.Security> = ThrowingLazyWeakReference { [unowned self] in
        guard let beacon = Beacon.shared else {
            throw Beacon.Error.unknown
        }
        
        return Transport.P2P.Matrix.Security(app: beacon.app, crypto: self.crypto, time: self.time)
    }
    
    func p2pMatrixStore(urlSession: URLSession, matrixNodes: [String]) throws -> Transport.P2P.Matrix.Store {
        guard let beacon = Beacon.shared else {
            throw Beacon.Error.unknown
        }
        
        return Transport.P2P.Matrix.Store(
            app: beacon.app,
            communicator: try p2pMatrixCommunicator(),
            matrixClient: matrixClient(urlSession: urlSession),
            matrixNodes: matrixNodes,
            storageManager: storageManager,
            migration: migration
        )
    }
    
    // MARK: Matrix
    
    func matrixClient(urlSession: URLSession) -> MatrixClient {
        let http = self.http(urlSession: urlSession)
        
        return MatrixClient(
            store: MatrixClient.Store(storageManager: storageManager),
            nodeService: MatrixClient.NodeService(http: http),
            userService: MatrixClient.UserService(http: http),
            eventService: MatrixClient.EventService(http: http),
            roomService: MatrixClient.RoomService(http: http),
            time: time
        )
    }
    
    // MARK: Derived
    
    var storageManager: StorageManager { dependencyRegistry.storageManager }
    
    func connectionController(configuredWith connections: [Beacon.Connection]) throws -> ConnectionControllerProtocol {
        try dependencyRegistry.connectionController(configuredWith: connections)
    }
    
    var messageController: MessageControllerProtocol { dependencyRegistry.messageController }
    
    func transport(configuredWith connection: Beacon.Connection) throws -> Transport {
        try dependencyRegistry.transport(configuredWith: connection)
    }
    
    var blockchainRegistry: BlockchainRegistryProtocol { dependencyRegistry.blockchainRegistry }
    var crypto: Crypto { dependencyRegistry.crypto }
    var serializer: Serializer { dependencyRegistry.serializer }
    
    func http(urlSession: URLSession) -> HTTP {
        dependencyRegistry.http(urlSession: urlSession)
    }
    
    var migration: Migration {
        dependencyRegistry.migration.register([
            Migration.P2PMatrix.From1_0_4(storageManager: self.storageManager)
        ])
        
        return dependencyRegistry.migration
    }
    
    var identifierCreator: IdentifierCreatorProtocol { dependencyRegistry.identifierCreator }
    var time: TimeProtocol { dependencyRegistry.time }
}
