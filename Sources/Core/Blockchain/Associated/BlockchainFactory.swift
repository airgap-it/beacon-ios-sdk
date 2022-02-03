//
//  BlockchainFactory.swift
//  
//
//  Created by Julia Samol on 01.10.21.
//

import Foundation

public protocol BlockchainFactory {
    static var identifier: String { get }
    
    func afterInitialized(with dependencyRegistry: DependencyRegistry, completion: @escaping (Result<(), Error>) -> ())
    func createShadow(with dependencyRegistry: DependencyRegistry) -> ShadowBlockchain
}

// MARK: Extensions

public extension BlockchainFactory {

    func afterInitialized(with dependencyRegistry: DependencyRegistry, completion: @escaping (Result<(), Error>) -> ()) {
        /* no action */
        completion(.success(()))
    }
}
