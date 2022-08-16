//
//  WalletClientDependencyRegistry.swift
//  
//
//  Created by Julia Samol on 15.08.22.
//

import Foundation
import BeaconCore

class WalletClientDependencyRegistry: ExtendedDependencyRegistry {
    private let dependencyRegistry: DependencyRegistry
    
    init(dependencyRegistry: DependencyRegistry) {
        self.dependencyRegistry = dependencyRegistry
    }
    
    // MARK: Client
    
    private var walletClient: Beacon.WalletClient? = nil
    func walletClient(connections: [Beacon.Connection]) throws -> Beacon.WalletClient {
        guard let walletClient = walletClient else {
            let beacon = try beacon()
            
            let walletClient = Beacon.WalletClient(
                app: beacon.app,
                beaconID: beacon.beaconID,
                storageManager: storageManager,
                connectionController: try connectionController(configuredWith: connections),
                messageController: messageController,
                crypto: crypto,
                serializer: serializer
            )
            
            self.walletClient = walletClient
            return walletClient
        }
        
        return walletClient
    }
    
    // MARK: Derived
    
    var extended: [String: DependencyRegistry] { dependencyRegistry.extended }
    
    func addExtended<T>(_ registry: T) where T : DependencyRegistry {
        dependencyRegistry.addExtended(registry)
    }
    
    func findExtended<T>() -> T? where T : DependencyRegistry {
        dependencyRegistry.findExtended()
    }
    
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
    
    var migration: Migration { dependencyRegistry.migration }
    
    var identifierCreator: IdentifierCreatorProtocol { dependencyRegistry.identifierCreator }
    var time: TimeProtocol { dependencyRegistry.time }
    
    func afterInitialization(completion: @escaping (Result<(), Error>) -> ()) {
        dependencyRegistry.afterInitialization(completion: completion)
    }
}
