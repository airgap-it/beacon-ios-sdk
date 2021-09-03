//
//  ExtendedStorage.swift
//  BeaconSDK
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
    
    func add(
        _ appMetadata: [Beacon.AppMetadata],
        overwrite: Bool,
        compareBy predicate: @escaping (Beacon.AppMetadata, Beacon.AppMetadata) -> Bool,
        completion: @escaping (Result<(), Error>) -> ()
    )
    
    func findAppMetadata(where predicate: @escaping (Beacon.AppMetadata) -> Bool, completion: @escaping (Result<Beacon.AppMetadata?, Error>) -> ())
    func removeAppMetadata(where predicate: ((Beacon.AppMetadata) -> Bool)?, completion: @escaping (Result<(), Error>) -> ())
    
    // MARK: Permissions
    
    func add(
        _ permissions: [Beacon.Permission],
        overwrite: Bool,
        compareBy predicate: @escaping (Beacon.Permission, Beacon.Permission) -> Bool,
        completion: @escaping (Result<(), Error>) -> ()
    )
    
    func findPermissions(
        where predicate: @escaping (Beacon.Permission) -> Bool,
        completion: @escaping (Result<Beacon.Permission?, Error>) -> ()
    )
    
    func removePermissions(where predicate: ((Beacon.Permission) -> Bool)?, completion: @escaping (Result<(), Error>) -> ())
    
    // MARK: Matrix
    
    func removeMatrixRelayServer(completion: @escaping (Result<(), Error>) -> ())
    func removeMatrixChannels(completion: @escaping (Result<(), Error>) -> ())
    func removeMatrixRooms(completion: @escaping (Result<(), Error>) -> ())
    
    
    // MARK: SDK
    
    func addMigrations(_ migrations: Set<String>, completion: @escaping (Result<(), Error>) -> ())
}

// MARK: Extensions

extension ExtendedStorage {
    
    func extend() -> ExtendedStorage {
        self
    }
}
