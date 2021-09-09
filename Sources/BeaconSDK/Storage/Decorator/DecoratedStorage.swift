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
    
    func getPeers(completion: @escaping (Result<[Beacon.Peer], Error>) -> ()) {
        storage.getPeers(completion: completion)
    }
    
    func set(_ peers: [Beacon.Peer], completion: @escaping (Result<(), Error>) -> ()) {
        storage.set(peers, completion: completion)
    }
    
    func add(
        _ peers: [Beacon.Peer],
        overwrite: Bool,
        compareBy predicate: @escaping (Beacon.Peer, Beacon.Peer) -> Bool,
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
    
    func findPeers(where predicate: @escaping (Beacon.Peer) -> Bool, completion: @escaping (Result<Beacon.Peer?, Error>) -> ()) {
        find(where: predicate, select: storage.getPeers, completion: completion)
    }
    
    func removePeers(where predicate: ((Beacon.Peer) -> Bool)?, completion: @escaping (Result<(), Error>) -> ()) {
        remove(where: predicate, select: storage.getPeers, insert: storage.set, completion: completion)
    }
    
    // MARK: AppMetadata
    
    func getAppMetadata(completion: @escaping (Result<[Beacon.AppMetadata], Error>) -> ()) {
        storage.getAppMetadata(completion: completion)
    }
    
    func set(_ appMetadata: [Beacon.AppMetadata], completion: @escaping (Result<(), Error>) -> ()) {
        storage.set(appMetadata, completion: completion)
    }
    
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
    
    func removeAppMetadata(where predicate: ((Beacon.AppMetadata) -> Bool)?, completion: @escaping (Result<(), Error>) -> ()) {
        remove(where: predicate, select: storage.getAppMetadata, insert: storage.set, completion: completion)
    }
    
    // MARK: Permissions
    
    func getPermissions(completion: @escaping (Result<[Beacon.Permission], Error>) -> ()) {
        storage.getPermissions(completion: completion)
    }
    
    func set(_ permissions: [Beacon.Permission], completion: @escaping (Result<(), Error>) -> ()) {
        storage.set(permissions, completion: completion)
    }
    
    func add(
        _ permissions: [Beacon.Permission],
        overwrite: Bool,
        compareBy predicate: @escaping (Beacon.Permission, Beacon.Permission) -> Bool,
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
    
    func findPermissions(
        where predicate: @escaping (Beacon.Permission) -> Bool,
        completion: @escaping (Result<Beacon.Permission?, Error>) -> ()
    ) {
        find(where: predicate, select: storage.getPermissions, completion: completion)
    }
    
    func removePermissions(where predicate: ((Beacon.Permission) -> Bool)?, completion: @escaping (Result<(), Error>) -> ()) {
        remove(where: predicate, select: storage.getPermissions, insert: storage.set, completion: completion)
    }
    
    // MARK: Matrix
    
    func getMatrixRelayServer(completion: @escaping (Result<String?, Error>) -> ()) {
        storage.getMatrixRelayServer(completion: completion)
    }
    
    func setMatrixRelayServer(_ relayServer: String?, completion: @escaping (Result<(), Error>) -> ()) {
        storage.setMatrixRelayServer(relayServer, completion: completion)
    }
    
    func removeMatrixRelayServer(completion: @escaping (Result<(), Error>) -> ()) {
        storage.setMatrixRelayServer(nil, completion: completion)
    }
    
    func getMatrixChannels(completion: @escaping (Result<[String : String], Error>) -> ()) {
        storage.getMatrixChannels(completion: completion)
    }
    
    func setMatrixChannels(_ channels: [String : String], completion: @escaping (Result<(), Error>) -> ()) {
        storage.setMatrixChannels(channels, completion: completion)
    }
    
    func removeMatrixChannels(completion: @escaping (Result<(), Error>) -> ()) {
        storage.setMatrixChannels([:], completion: completion)
    }
    
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
    
    func removeMatrixRooms(completion: @escaping (Result<(), Error>) -> ()) {
        storage.set([Matrix.Room](), completion: completion)
    }
    
    // MARK: SDK
    
    func getSDKVersion(completion: @escaping (Result<String?, Error>) -> ()) {
        storage.getSDKVersion(completion: completion)
    }
    
    func setSDKVersion(_ version: String, completion: @escaping (Result<(), Error>) -> ()) {
        storage.setSDKVersion(version, completion: completion)
    }
    
    func getMigrations(completion: @escaping (Result<Set<String>, Error>) -> ()) {
        storage.getMigrations(completion: completion)
    }
    
    func setMigrations(_ migrations: Set<String>, completion: @escaping (Result<(), Error>) -> ()) {
        storage.setMigrations(migrations, completion: completion)
    }
    
    func addMigrations(_ migrations: Set<String>, completion: @escaping (Result<(), Error>) -> ()) {
        storage.getMigrations { result in
            guard let oldMigrations = result.get(ifFailure: completion) else { return }
            self.storage.setMigrations(oldMigrations.union(migrations), completion: completion)
        }
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
                insert(stored.filter { !predicate($0) }, completion)
            }
        } else {
            removeAll(insert: insert, completion: completion)
        }
    }
    
    private func removeAll<T>(insert: InsertCollection<T>, completion: @escaping (Result<(), Error>) -> ()) {
        insert([], completion)
    }
}
