//
//  ExtendedDependencyRegistry.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

protocol ExtendedDependencyRegistry: DependencyRegistry {
    
    // MARK: Wallet
    
    var substrateWallet: Substrate.Wallet { get }
    
    // MARK: Creator
    
    var substrateCreator: Substrate.Creator { get }
}

extension DependencyRegistry {
    func extend() -> ExtendedDependencyRegistry {
        guard let extended = (self as? SubstrateDependencyRegistry) ?? findExtended() else {
            let extended = SubstrateDependencyRegistry(dependencyRegistry: self)
            addExtended(extended)
            
            return extended
        }
        
        return extended
    }
}
