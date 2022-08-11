//
//  ExtendedDependencyRegistry.swift
//  
//
//  Created by Julia Samol on 11.08.22.
//

import Foundation
import BeaconCore

protocol ExtendedDependencyRegistry: DependencyRegistry {
    
    // MARK: Controllers
    
    var accountController: AccountControllerProtocol { get }
}

extension DependencyRegistry {
    func extend() -> ExtendedDependencyRegistry {
        guard let extended = (self as? DAppClientDependencyRegistry) ?? findExtended() else {
            let extended = DAppClientDependencyRegistry(dependencyRegistry: self)
            addExtended(extended)
            
            return extended
        }
        
        return extended
    }
}
