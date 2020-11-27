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
        _ peers: [Beacon.PeerInfo],
        overwrite: Bool,
        compareBy predicate: @escaping (Beacon.PeerInfo, Beacon.PeerInfo) -> Bool,
        completion: @escaping (Result<(), Error>) -> ()
    )
    
    func removePeers(where predicate: ((Beacon.PeerInfo) -> Bool)?, completion: @escaping (Result<(), Error>) -> ())
    
    // MARK: AppMetadata
    
    func add(
        _ appMetadata: [Beacon.AppMetadata],
        overwrite: Bool,
        compareBy predicate: @escaping (Beacon.AppMetadata, Beacon.AppMetadata) -> Bool,
        completion: @escaping (Result<(), Error>) -> ()
    )
    
    func findAppMetadata(where predicate: @escaping (Beacon.AppMetadata) -> Bool, completion: @escaping (Result<Beacon.AppMetadata?, Error>) -> ())
    
    // MARK: Permissions
    
    func add(
        _ permissions: [Beacon.PermissionInfo],
        overwrite: Bool,
        compareBy predicate: @escaping (Beacon.PermissionInfo, Beacon.PermissionInfo) -> Bool,
        completion: @escaping (Result<(), Error>) -> ()
    )
    
    func removePermissions(where predicate: ((Beacon.PermissionInfo) -> Bool)?, completion: @escaping (Result<(), Error>) -> ())
}
