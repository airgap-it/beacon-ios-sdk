//
//  P2PMatrixMigrationTarget.swift
//  
//
//  Created by Julia Samol on 27.09.21.
//

import Foundation
import BeaconCore

extension Migration.P2PMatrix {
    
    enum Target: MigrationTarget {
        case matrixRelayServer(MatrixRelayServer)
        
        // MARK: Attributes
        
        var identifier: String { common.identifier }
        
        var common: MigrationTarget {
            switch self {
            case let .matrixRelayServer(content):
                return content
            }
        }

        
        // MARK: Structs
        
        struct MatrixRelayServer: MigrationTarget {
            let identifier: String = "matrixRelayServer"
            
            let matrixNodes: [String]
        }
    }
}
