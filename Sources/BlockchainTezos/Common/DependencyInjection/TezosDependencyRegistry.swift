//
//  TezosDependencyRegistry.swift
//  
//
//  Created by Julia Samol on 06.01.22.
//

import Foundation
import BeaconCore

class TezosDependencyRegistry: ExtendedDependencyRegistry {
    private let dependencyRegistry: DependencyRegistry
    
    init(dependencyRegistry: DependencyRegistry) {
        self.dependencyRegistry = dependencyRegistry
    }
    
    // MARK: Wallet
    
    var tezosWallet: Tezos.Wallet { weakTezosWallet.value }
    private lazy var weakTezosWallet: LazyWeakReference<Tezos.Wallet> = LazyWeakReference { [unowned self] in
        Tezos.Wallet(crypto: self.crypto)
    }
    
    // MARK: Creator
    
    var tezosCreator: Tezos.Creator { weakTezosCreator.value }
    private lazy var weakTezosCreator: LazyWeakReference<Tezos.Creator> = LazyWeakReference { [unowned self] in
        Tezos.Creator(wallet: self.tezosWallet, storageManager: self.storageManager, identifierCreator: self.identifierCreator, time: self.time)
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
}
