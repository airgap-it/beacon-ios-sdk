//
//  SubstrateDependencyRegistry.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

class SubstrateDependencyRegistry: ExtendedDependencyRegistry {
    private let dependencyRegistry: DependencyRegistry
    
    init(dependencyRegistry: DependencyRegistry) {
        self.dependencyRegistry = dependencyRegistry
    }
    
    // MARK: Blockchain
    
    var substrate: Substrate { weakSubstrate.value }
    private lazy var weakSubstrate: LazyWeakReference<Substrate> = LazyWeakReference { [unowned self] in
        Substrate(creator: substrateCreator, storageExtension: substrateStorageExtension)
    }
    
    // MARK: Creator
    
    var substrateCreator: Substrate.Creator { weakSubstrateCreator.value }
    private lazy var weakSubstrateCreator: LazyWeakReference<Substrate.Creator> = LazyWeakReference { [unowned self] in
        Substrate.Creator(storageManager: self.storageManager, identifierCreator: self.identifierCreator, time: self.time)
    }
    
    // MARK: StorageExtension
    
    var substrateStorageExtension: Substrate.StorageExtension { weakSubstrateStorageExtension.value }
    private lazy var weakSubstrateStorageExtension: LazyWeakReference<Substrate.StorageExtension> = LazyWeakReference { [unowned self] in
        Substrate.StorageExtension(storage: self.storageManager)
    }
    
    // MARK: Derived
    
    var extended: [String : DependencyRegistry] { dependencyRegistry.extended }
    
    func addExtended<T>(_ extended: T) where T : DependencyRegistry {
        dependencyRegistry.addExtended(extended)
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
