//
//  BlockchainFactory.swift
//  
//
//  Created by Julia Samol on 01.10.21.
//

import Foundation

public protocol BlockchainFactory {
    static var identifier: String { get }
    func createBoxed(with dependencyRegistry: DependencyRegistry) -> AnyBlockchain
}
