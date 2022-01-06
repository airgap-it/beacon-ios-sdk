//
//  ExtendedDependencyRegistry.swift
//  
//
//  Created by Julia Samol on 06.01.22.
//

import Foundation
import BeaconCore

protocol ExtendedDependencyRegistry: DependencyRegistry {
    
    // MARK: Wallet
    
    var tezosWallet: Tezos.Wallet { get }
    
    // MARK: Creator
    
    var tezosCreator: Tezos.Creator { get }
    
    // MARK: Decoder
    
    var tezosDecoder: Tezos.Decoder { get }
}

extension DependencyRegistry {
    func extend() -> ExtendedDependencyRegistry {
        guard let extended = (self as? TezosDependencyRegistry) ?? findExtended() else {
            let extended = TezosDependencyRegistry(dependencyRegistry: self)
            addExtended(extended)
            
            return extended
        }
        
        return extended
    }
}
