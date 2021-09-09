//
//  MigrationTarget.swift
//  
//
//  Created by Julia Samol on 27.08.21.
//

import Foundation

extension Migration {
    
    enum Target {
        case matrixRelayServer(MatrixRelayServer)
        
        // MARK: Attributes
        
        var common: TargetProtocol {
            switch self {
            case let .matrixRelayServer(content):
                return content
            }
        }
        
        // MARK: Structs
        
        struct MatrixRelayServer: TargetProtocol {
            let identifier: String = "matrixRelayServer"
            
            let matrixNodes: [String]
        }
    }
}

// MARK: Protocol

protocol TargetProtocol {
    var identifier: String { get }
}
