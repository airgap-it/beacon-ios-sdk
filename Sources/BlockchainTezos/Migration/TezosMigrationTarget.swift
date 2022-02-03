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
        case permissions(Permissions)
        
        // MARK: Attributes
        
        var identifier: String { common.identifier }
        
        var common: MigrationTarget {
            switch self {
            case let .permissions(content):
                return content
            }
        }
        
        // MARK: Structs
        
        struct Permissions: MigrationTarget {
            let identifier: String = "permissions"
        }
    }
}
