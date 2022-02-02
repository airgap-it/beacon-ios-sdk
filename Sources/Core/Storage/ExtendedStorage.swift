//
//  ExtendedStorage.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

protocol ExtendedStorage: Storage {
    
    // MARK: Peers
    
    func add(
        _ peers: [Beacon.Peer],
        overwrite: Bool,
        compareBy predicate: @escaping (Beacon.Peer, Beacon.Peer) -> Bool,
        completion: @escaping (Result<(), Error>) -> ()
    )
    
    func findPeers(where predicate: @escaping (Beacon.Peer) -> Bool, completion: @escaping (Result<Beacon.Peer?, Error>) -> ())
    func removePeers(where predicate: ((Beacon.Peer) -> Bool)?, completion: @escaping (Result<(), Error>) -> ())
    
    // MARK: AppMetadata
    
    func add<T: AppMetadataProtocol>(
        _ appMetadata: [T],
        overwrite: Bool,
        compareBy predicate: @escaping (T, T) -> Bool,
        completion: @escaping (Result<(), Error>) -> ()
    )
    
    func findAppMetadata<T: AppMetadataProtocol>(where predicate: @escaping (T) -> Bool, completion: @escaping (Result<T?, Error>) -> ())
    func removeAppMetadata<T: AppMetadataProtocol>(where predicate: ((T) -> Bool)?, completion: @escaping (Result<(), Error>) -> ())
    
    // MARK: Permissions
    
    func add<T: PermissionProtocol>(
        _ permissions: [T],
        overwrite: Bool,
        compareBy predicate: @escaping (T, T) -> Bool,
        completion: @escaping (Result<(), Error>) -> ()
    )
    
    func findPermissions<T: PermissionProtocol>(
        where predicate: @escaping (T) -> Bool,
        completion: @escaping (Result<T?, Error>) -> ()
    )
    
    func removePermissions<T: PermissionProtocol>(where predicate: ((T) -> Bool)?, completion: @escaping (Result<(), Error>) -> ())
    
    // MARK: SDK
    
    func addMigrations(_ migrations: Set<String>, completion: @escaping (Result<(), Error>) -> ())
}

// MARK: Extensions

extension ExtendedStorage {
    
    func extend() -> ExtendedStorage {
        self
    }
}
