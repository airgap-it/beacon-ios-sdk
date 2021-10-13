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
    public struct Factory: BlockchainFactory {
        public static let identifier: String = Tezos.identifier
        
        public func create(with dependencyRegistry: DependencyRegistry) -> Tezos {
            let wallet = Wallet(crypto: dependencyRegistry.crypto)
            let creator = Creator(
                wallet: wallet,
                storageManager: dependencyRegistry.storageManager,
                identifierCreator: dependencyRegistry.identifierCreator,
                time: dependencyRegistry.time
            )
            let decoder = Decoder()
         
            return Tezos(wallet: wallet, creator: creator, decoder: decoder)
        }
        
        public func createShadow(with dependencyRegistry: DependencyRegistry) -> ShadowBlockchain {
            create(with: dependencyRegistry)
        }
    }
}
