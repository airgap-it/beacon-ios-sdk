//
//  ExtendedDependencyRegistry.swift
//  
//
//  Created by Julia Samol on 27.09.21.
//

import Foundation
import BeaconCore

protocol ExtendedDependencyRegistry: DependencyRegistry {
    
    // MARK: Client
    
    func p2pMatrix(storagePlugin: P2PMatrixStoragePlugin, matrixNodes: [String], urlSession: URLSession) throws -> Transport.P2P.Matrix
    
    // MARK: P2P
    
    func p2pMatrixCommunicator() throws -> Transport.P2P.Matrix.Communicator
    func p2pMatrixSecurity() throws -> Transport.P2P.Matrix.Security
    func p2pMatrixStore(urlSession: URLSession, matrixNodes: [String]) throws -> Transport.P2P.Matrix.Store
    
    // MARK: Matrix
    
    func matrixClient(urlSession: URLSession) throws -> MatrixClient
}

extension DependencyRegistry {
    func extend() -> ExtendedDependencyRegistry {
        guard let extended = (self as? P2PMatrixDependencyRegistry) ?? findExtended() else {
            let extended = P2PMatrixDependencyRegistry(dependencyRegistry: self)
            addExtended(extended)
            
            return extended
        }
        
        return extended
    }
}
