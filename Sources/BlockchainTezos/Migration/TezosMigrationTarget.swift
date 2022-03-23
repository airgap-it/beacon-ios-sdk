//
//  TezosMigrationTarget.swift
//  
//
//  Created by Julia Samol on 02.02.22.
//

import Foundation
import BeaconCore

extension Migration.Tezos {
    
    enum Target: MigrationTarget {
        case storage(Storage)
        
        // MARK: Attributes
        
        var identifier: String { common.identifier }
        
        var common: MigrationTarget {
            switch self {
            case let .storage(content):
                return content
            }
        }
        
        // MARK: Structs
        
        struct Storage: MigrationTarget {
            let identifier: String = "storage"
        }
    }
}
