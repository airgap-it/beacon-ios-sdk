//
//  Factory.swift
//  
//
//  Created by Julia Samol on 30.09.21.
//

import Foundation
import BeaconCore

extension Tezos {
    
    /// Tezos factory that should be used to dynamically register the blockchain in Beacon.
    public class Factory: BlockchainFactory {
        public static let identifier: String = Tezos.identifier
        
        private var extendedDependencyRegistry: ExtendedDependencyRegistry?
        private func extendedDependencyRegistry(from dependencyRegistry: DependencyRegistry) -> ExtendedDependencyRegistry {
            guard let value = extendedDependencyRegistry else {
                let value = dependencyRegistry.extend()
                extendedDependencyRegistry = value
                
                return value
            }
            
            return value
        }
        
        public func create(with dependencyRegistry: DependencyRegistry) -> Tezos {
            let extendedDependencyRegistry = extendedDependencyRegistry(from: dependencyRegistry)
         
            return Tezos(
                wallet: extendedDependencyRegistry.tezosWallet,
                creator: extendedDependencyRegistry.tezosCreator,
                storageExtension: extendedDependencyRegistry.tezosStorageExtension
            )
        }
        
        public func createShadow(with dependencyRegistry: DependencyRegistry) -> ShadowBlockchain {
            create(with: dependencyRegistry)
        }
        
        public func afterInitialized(with dependencyRegistry: DependencyRegistry, completion: @escaping ((Result<(), Error>) -> ())) {
            let extendedDependencyRegistry = extendedDependencyRegistry(from: dependencyRegistry)
            let migration = extendedDependencyRegistry.migration

            migration.migrateStorage(completion: completion)
        }
    }
}
