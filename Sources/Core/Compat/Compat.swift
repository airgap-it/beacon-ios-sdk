//
//  Compat.swift
//  
//
//  Created by Julia Samol on 08.10.21.
//

import Foundation

public class Compat {
    public static var shared: Compat?
    
    private init(versioned: [VersionedCompat] = []) {
        self.register(versioned)
    }
    
    private var allVersioned: [VersionedCompat] = []
    public func versioned() throws -> VersionedCompat {
        guard let versioned = allVersioned.last(where: { $0.withVersion < Beacon.Configuration.sdkVersion }) ?? allVersioned.last else {
            throw Error.missingVersionedCompats
        }
        
        return versioned
    }
    
    public static func initialize(with dependencyRegistry: DependencyRegistry) {
        shared = Compat(versioned: [CompatWith2_0_0(blockchainRegistry: dependencyRegistry.blockchainRegistry)])
    }
    
    public func register(_ additionalVersioned: [VersionedCompat]) {
        allVersioned.append(contentsOf: additionalVersioned)
    }
    
    // MARK: Types
    
    enum Error: Swift.Error {
        case missingVersionedCompats
    }
}
