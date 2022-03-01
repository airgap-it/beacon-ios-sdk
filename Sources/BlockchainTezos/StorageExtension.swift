//
//  StorageExtension.swift
//  
//
//  Created by Julia Samol on 28.02.22.
//

import Foundation
import BeaconCore

extension Tezos {
    
    public class StorageExtension: BlockchainStorageExtension {
        private let storage: ExtendedStorage
        
        init(storage: ExtendedStorage) {
            self.storage = storage
        }
        
        public func removeAppMetadata(where predicate: ((AnyAppMetadata) -> Bool)? = nil, completion: @escaping (Result<(), Error>) -> ()) {
            storage.removeAppMetadata(ofType: AppMetadata.self, where: predicate, completion: completion)
        }
        
        public func removePermissions(where predicate: ((AnyPermission) -> Bool)? = nil, completion: @escaping (Result<(), Error>) -> ()) {
            storage.removePermissions(ofType: Permission.self, where: predicate, completion: completion)
        }
    }
}
