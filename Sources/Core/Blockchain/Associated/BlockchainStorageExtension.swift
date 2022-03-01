//
//  BlockchainStorageExtension.swift
//  
//
//  Created by Julia Samol on 28.02.22.
//

import Foundation

public protocol BlockchainStorageExtension {
    func removeAppMetadata(where predicate: ((AnyAppMetadata) -> Bool)?, completion: @escaping (Result<(), Error>) -> ())
    func removePermissions(where predicate: ((AnyPermission) -> Bool)?, completion: @escaping (Result<(), Error>) -> ())
}

// MARK: Any

struct AnyBlockchainStorageExtensions: BlockchainStorageExtension {
    private let storage: ExtendedStorage
    
    init(storage: ExtendedStorage) {
        self.storage = storage
    }
    
    func removeAppMetadata(where predicate: ((AnyAppMetadata) -> Bool)? = nil, completion: @escaping (Result<(), Error>) -> ()) {
        if let predicate = predicate {
            storage.removeAppMetadata(where: predicate, completion: completion)
        } else {
            storage.set([AnyAppMetadata](), completion: completion)
        }
    }
    
    func removePermissions(where predicate: ((AnyPermission) -> Bool)? = nil, completion: @escaping (Result<(), Error>) -> ()) {
        if let predicate = predicate {
            storage.removePermissions(where: predicate, completion: completion)
        } else {
            storage.set([AnyPermission](), completion: completion)
        }
    }
}
