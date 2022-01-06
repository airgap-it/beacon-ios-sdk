//
//  DecoratedStorage.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

private typealias SelectCollection<T> = (@escaping (Result<[T], Error>) -> ()) -> ()
private typealias InsertCollection<T> = ([T], @escaping (Result<(), Error>) -> ()) -> ()

struct DecoratedStorage: ExtendedStorage {
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
    
    func getAppMetadata<T: AppMetadataProtocol & Codable>(completion: @escaping (Result<[T], Error>) -> ()) {
        storage.getAppMetadata(completion: completion)
    }
    
    func set<T: AppMetadataProtocol & Codable>(_ appMetadata: [T], completion: @escaping (Result<(), Error>) -> ()) {
        storage.set(appMetadata, completion: completion)
    }
    
    func add<T: AppMetadataProtocol & Codable & Equatable>(
        _ appMetadata: [T],
        overwrite: Bool,
        compareBy predicate: @escaping (T, T) -> Bool,
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
    
    func findAppMetadata<T: AppMetadataProtocol & Codable>(
        where predicate: @escaping (T) -> Bool,
        completion: @escaping (Result<T?, Error>) -> ()
    ) {
        find(where: predicate, select: storage.getAppMetadata, completion: completion)
    }
    
    func removeAppMetadata<T: AppMetadataProtocol & Codable>(where predicate: ((T) -> Bool)?, completion: @escaping (Result<(), Error>) -> ()) {
        remove(where: predicate, select: storage.getAppMetadata, insert: storage.set, completion: completion)
    }
    
    // MARK: Permissions
    
    func getPermissions<T: PermissionProtocol & Codable>(completion: @escaping (Result<[T], Error>) -> ()) {
        storage.getPermissions(completion: completion)
    }
    
    func set<T: PermissionProtocol & Codable>(_ permissions: [T], completion: @escaping (Result<(), Error>) -> ()) {
        storage.set(permissions, completion: completion)
    }
    
    func add<T: PermissionProtocol & Codable & Equatable>(
        _ permissions: [T],
        overwrite: Bool,
        compareBy predicate: @escaping (T, T) -> Bool,
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
    
    func findPermissions<T: PermissionProtocol & Codable>(
        where predicate: @escaping (T) -> Bool,
        completion: @escaping (Result<T?, Error>) -> ()
    ) {
        find(where: predicate, select: storage.getPermissions, completion: completion)
    }
    
    func removePermissions<T: PermissionProtocol & Codable>(where predicate: ((T) -> Bool)?, completion: @escaping (Result<(), Error>) -> ()) {
        remove(where: predicate, select: storage.getPermissions, insert: storage.set, completion: completion)
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
