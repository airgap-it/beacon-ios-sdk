//
//  Static.swift
//  
//
//  Created by Julia Samol on 05.01.22.
//

import Foundation

public func beacon() throws -> Beacon {
    guard let beacon = Beacon.shared else {
        throw Beacon.Error.uninitialized
    }

    return beacon
}

public func dependencyRegistry() throws -> DependencyRegistry {
    try beacon().dependencyRegistry
}

public func app() throws -> Beacon.Application {
    try beacon().app
}

public func blockchainRegistry() throws -> BlockchainRegistryProtocol {
    try dependencyRegistry().blockchainRegistry
}

public func compat() throws -> Compat {
    guard let compat = Compat.shared else {
        throw Beacon.Error.uninitialized
    }
    
    return compat
}
