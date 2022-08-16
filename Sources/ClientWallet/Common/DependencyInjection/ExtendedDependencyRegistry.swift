//
//  ExtendedDependencyRegistry.swift
//  
//
//  Created by Julia Samol on 15.08.22.
//

import Foundation
import BeaconCore

protocol ExtendedDependencyRegistry: DependencyRegistry {
    
    // MARK: Client
    
    func walletClient(connections: [Beacon.Connection]) throws -> Beacon.WalletClient
    
}

extension DependencyRegistry {
    func extend() -> ExtendedDependencyRegistry {
        guard let extended = (self as? WalletClientDependencyRegistry) ?? findExtended() else {
            let extended = WalletClientDependencyRegistry(dependencyRegistry: self)
            addExtended(extended)
            
            return extended
        }
        
        return extended
    }
}
