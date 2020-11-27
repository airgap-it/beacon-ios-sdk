//
//  DecoratedStorage.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

private typealias SelectCollection<T> = (@escaping (Result<[T], Error>) -> ()) -> ()
private typealias InsertCollection<T> = ([T], @escaping (Result<(), Error>) -> ()) -> ()

class DecoratedStorage: ExtendedStorage {
    private let storage: Storage
    
    init(storage: Storage) {
        self.storage = storage
    }
    
    // MARK: Peers
    
    func getPeers(completion: @escaping (Result<[Beacon.PeerInfo], Error>) -> ()) {
        storage.getPeers(completion: completion)
    }
    
    func set(_ peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Error>) -> ()) {
        storage.set(peers, completion: completion)
    }
    
    func add(
        _ peers: [Beacon.PeerInfo],
        overwrite: Bool,
        compareBy predicate: @escaping (Beacon.PeerInfo, Beacon.PeerInfo) -> Bool,
        completion: @escaping (Result<(), Error>) -> ()
    ) {
        add(
            peers,
            select: storage.getPeers,
            insert: storage.set,
            overwrite: overwrite,
            compareBy: predicate,
            completion: completion
        )
    }
    
    func removePeers(where predicate: ((Beacon.PeerInfo) -> Bool)?, completion: @escaping (Result<(), Error>) -> ()) {
        remove(where: predicate, select: storage.getPeers, insert: storage.set, completion: completion)
    }
    
    // MARK: AppMetadata
    
    func add(
        _ appMetadata: [Beacon.AppMetadata],
        overwrite: Bool,
        compareBy predicate: @escaping (Beacon.AppMetadata, Beacon.AppMetadata) -> Bool,
        completion: @escaping (Result<(), Error>) -> ()
    ) {
        add(
            appMetadata,
            select: storage.getAppMetadata,
            insert: storage.set,
            overwrite: overwrite,
            compareBy: predicate,
            completion: completion
        )
    }
    
    func findAppMetadata(
        where predicate: @escaping (Beacon.AppMetadata) -> Bool,
        completion: @escaping (Result<Beacon.AppMetadata?, Error>) -> ()
    ) {
        find(where: predicate, select: storage.getAppMetadata, completion: completion)
    }
    
    func getAppMetadata(completion: @escaping (Result<[Beacon.AppMetadata], Error>) -> ()) {
        storage.getAppMetadata(completion: completion)
    }
    
    func set(_ appMetadata: [Beacon.AppMetadata], completion: @escaping (Result<(), Error>) -> ()) {
        storage.set(appMetadata, completion: completion)
    }
    
    // MARK: Permissions
    
    func add(
        _ permissions: [Beacon.PermissionInfo],
        overwrite: Bool,
        compareBy predicate: @escaping (Beacon.PermissionInfo, Beacon.PermissionInfo) -> Bool,
        completion: @escaping (Result<(), Error>) -> ()
    ) {
        add(
            permissions,
            select: storage.getPermissions,
            insert: storage.set,
            overwrite: overwrite,
            compareBy: predicate,
            completion: completion
        )
    }
    
    func getPermissions(completion: @escaping (Result<[Beacon.PermissionInfo], Error>) -> ()) {
        storage.getPermissions(completion: completion)
    }
    
    func set(_ permissions: [Beacon.PermissionInfo], completion: @escaping (Result<(), Error>) -> ()) {
        storage.set(permissions, completion: completion)
    }
    
    func removePermissions(where predicate: ((Beacon.PermissionInfo) -> Bool)?, completion: @escaping (Result<(), Error>) -> ()) {
        remove(where: predicate, select: storage.getPermissions, insert: storage.set, completion: completion)
    }
    
    // MARK: Matrix
    
    func getMatrixSyncToken(completion: @escaping (Result<String?, Error>) -> ()) {
        storage.getMatrixSyncToken(completion: completion)
    }
    
    func setMatrixSyncToken(_ token: String, completion: @escaping (Result<(), Error>) -> ()) {
        storage.setMatrixSyncToken(token, completion: completion)
    }
    
    func getMatrixRooms(completion: @escaping (Result<[Matrix.Room], Error>) -> ()) {
        storage.getMatrixRooms(completion: completion)
    }
    
    func set(_ rooms: [Matrix.Room], completion: @escaping (Result<(), Error>) -> ()) {
        storage.set(rooms, completion: completion)
    }
    
    // MARK: SDK
    
    func getSDKSecretSeed(completion: @escaping (Result<String?, Error>) -> ()) {
        storage.getSDKSecretSeed(completion: completion)
    }
    
    func setSDKSecretSeed(_ seed: String, completion: @escaping (Result<(), Error>) -> ()) {
        storage.setSDKSecretSeed(seed, completion: completion)
    }
    
    func getSDKVersion(completion: @escaping (Result<String?, Error>) -> ()) {
        storage.getSDKVersion(completion: completion)
    }
    
    func setSDKVersion(_ version: String, completion: @escaping (Result<(), Error>) -> ()) {
        storage.setSDKVersion(version, completion: completion)
    }
    
    // MARK: Utils
    
    private func add<T: Equatable>(
        _ elements: [T],
        select: SelectCollection<T>,
        insert: @escaping InsertCollection<T>,
        overwrite: Bool,
        compareBy predicate: @escaping (T, T) -> Bool,
        completion: @escaping (Result<(), Error>) -> ()
    ) {
        select { result in
            guard var stored = result.get(ifFailure: completion) else { return }
            let (new, existing) = elements.partitioned { toAdd in
                !stored.contains { inStorage in predicate(toAdd, inStorage) }
            }
            
            if overwrite {
                existing.forEach {
                    if let index = stored.firstIndex(of: $0) {
                        stored[index] = $0
                    }
                }
            }
            
            insert(stored + new, completion)
        }
    }
    
    private func find<T>(
        where predicate: @escaping (T) -> Bool,
        select: SelectCollection<T>,
        completion: @escaping (Result<T?, Error>) -> ()
    ) {
        select { result in
            completion(result.map { $0.first(where: predicate) })
        }
    }
    
    private func remove<T>(
        where predicate: ((T) -> Bool)?,
        select: SelectCollection<T>,
        insert: @escaping InsertCollection<T>,
        completion: @escaping (Result<(), Error>) -> ()
    ) {
        if let predicate = predicate {
            select { result in
                guard let stored = result.get(ifFailure: completion) else { return }
                insert(stored.filter(predicate), completion)
            }
        } else {
            removeAll(insert: insert, completion: completion)
        }
    }
    
    private func removeAll<T>(insert: InsertCollection<T>, completion: @escaping (Result<(), Error>) -> ()) {
        insert([], completion)
    }
}
