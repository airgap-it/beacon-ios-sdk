//
//  Factory.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

extension Substrate {
    
    /// Substrate factory that should be used to dynamically register the blockchain in Beacon.
    public class Factory: BlockchainFactory {
        public static let identifier: String = Substrate.identifier
        
        private var extendedDependencyRegistry: ExtendedDependencyRegistry?
        private func extendedDependencyRegistry(from dependencyRegistry: DependencyRegistry) -> ExtendedDependencyRegistry {
            guard let value = extendedDependencyRegistry else {
                let value = dependencyRegistry.extend()
                extendedDependencyRegistry = value
                
                return value
            }
            
            return value
        }
        
        public func create(with dependencyRegistry: DependencyRegistry) -> Substrate {
            let extendedDependencyRegistry = extendedDependencyRegistry(from: dependencyRegistry)
            
            return Substrate(
                wallet: extendedDependencyRegistry.substrateWallet,
                creator: extendedDependencyRegistry.substrateCreator,
                storageExtension: extendedDependencyRegistry.substrateStorageExtension
            )
        }
        
        public func createShadow(with dependencyRegistry: DependencyRegistry) -> ShadowBlockchain {
            create(with: dependencyRegistry)
        }
    }
}
