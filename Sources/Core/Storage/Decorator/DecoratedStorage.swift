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

private typealias TransformElement<T, S> = (T) -> S

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
        distinguishBy selectKeys: @escaping (Beacon.Peer) -> [AnyHashable],
        completion: @escaping (Result<(), Error>) -> ()
    ) {
        add(
            peers,
            select: storage.getPeers,
            insert: storage.set,
            overwrite: overwrite,
            distinguishBy: selectKeys,
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
    
    func getAppMetadata<T: AppMetadataProtocol>(completion: @escaping (Result<[T], Error>) -> ()) {
        storage.getAppMetadata(completion: completion)
    }
    
    func set<T: AppMetadataProtocol>(_ appMetadata: [T], completion: @escaping (Result<(), Error>) -> ()) {
        storage.set(appMetadata, completion: completion)
    }
    
    func add<T: AppMetadataProtocol>(
        _ appMetadata: [T],
        overwrite: Bool,
        distinguishBy selectKeys: @escaping (T) -> [AnyHashable],
        completion: @escaping (Result<(), Error>) -> ()
    ) {
        add(
            appMetadata,
            select: storage.getAppMetadata,
            insert: storage.set,
            overwrite: overwrite,
            distinguishBy: selectKeys,
            completion: completion
        )
    }
    
    func findAppMetadata<T: AppMetadataProtocol>(
        where predicate: @escaping (T) -> Bool,
        completion: @escaping (Result<T?, Error>) -> ()
    ) {
        find(where: predicate, select: storage.getAppMetadata, completion: completion)
    }
    
    func removeAppMetadata<T: AppMetadataProtocol>(where predicate: @escaping ((T) -> Bool), completion: @escaping (Result<(), Error>) -> ()) {
        remove(where: predicate, select: storage.getAppMetadata, insert: storage.set, completion: completion)
    }
    
    func removeAppMetadata<T: AppMetadataProtocol>(ofType type: T.Type, where predicate: ((AnyAppMetadata) -> Bool)? = nil, completion: @escaping (Result<(), Error>) -> ()) {
        if let predicate = predicate {
            remove(
                where: predicate,
                transform: { (appMetadata: T) in AnyAppMetadata(appMetadata) },
                select: storage.getAppMetadata,
                insert: storage.set,
                completion: completion
            )
        } else {
            removeAll(ofType: T.self, insert: storage.set, completion: completion)
        }
    }
    
    func getLegacyAppMetadata<T: LegacyAppMetadataProtocol>(completion: @escaping (Result<[T], Error>) -> ()) {
        storage.getLegacyAppMetadata(completion: completion)
    }
    
    func setLegacy<T: LegacyAppMetadataProtocol>(_ appMetadata: [T], completion: @escaping (Result<(), Error>) -> ()) {
        storage.setLegacy(appMetadata, completion: completion)
    }
    
    func removeLegacyAppMetadata<T: LegacyAppMetadataProtocol>(ofType type: T.Type, completion: @escaping (Result<(), Error>) -> ()) {
        removeAll(ofType: T.self, insert: storage.setLegacy, completion: completion)
    }
    
    // MARK: Permissions
    
    func getPermissions<T: PermissionProtocol>(completion: @escaping (Result<[T], Error>) -> ()) {
        storage.getPermissions(completion: completion)
    }
    
    func set<T: PermissionProtocol>(_ permissions: [T], completion: @escaping (Result<(), Error>) -> ()) {
        storage.set(permissions, completion: completion)
    }
    
    func add<T: PermissionProtocol>(
        _ permissions: [T],
        overwrite: Bool,
        distinguishBy selectKeys: @escaping (T) -> [AnyHashable],
        completion: @escaping (Result<(), Error>) -> ()
    ) {
        add(
            permissions,
            select: storage.getPermissions,
            insert: storage.set,
            overwrite: overwrite,
            distinguishBy: selectKeys,
            completion: completion
        )
    }
    
    func findPermissions<T: PermissionProtocol>(
        where predicate: @escaping (T) -> Bool,
        completion: @escaping (Result<T?, Error>) -> ()
    ) {
        find(where: predicate, select: storage.getPermissions, completion: completion)
    }
    
    func removePermissions<T: PermissionProtocol>(where predicate: @escaping ((T) -> Bool), completion: @escaping (Result<(), Error>) -> ()) {
        remove(where: predicate, select: storage.getPermissions, insert: storage.set, completion: completion)
    }
    
    func removePermissions<T: PermissionProtocol>(ofType type: T.Type, where predicate: ((AnyPermission) -> Bool)? = nil, completion: @escaping (Result<(), Error>) -> ()) {
        if let predicate = predicate {
            remove(
                where: predicate,
                transform: { (permission: T) in AnyPermission(permission) },
                select: storage.getPermissions,
                insert: storage.set,
                completion: completion
            )
        } else {
            removeAll(ofType: T.self, insert: storage.set, completion: completion)
        }
    }
    
    func getLegacyPermissions<T: LegacyPermissionProtocol>(completion: @escaping (Result<[T], Error>) -> ()) {
        storage.getLegacyPermissions(completion: completion)
    }
    
    func setLegacy<T: LegacyPermissionProtocol>(_ permissions: [T], completion: @escaping (Result<(), Error>) -> ()) {
        storage.setLegacy(permissions, completion: completion)
    }
    
    func removeLegacyPermissions<T: LegacyPermissionProtocol>(ofType type: T.Type, completion: @escaping (Result<(), Error>) -> ()) {
        removeAll(ofType: T.self, insert: storage.setLegacy, completion: completion)
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
        distinguishBy selectKeys: @escaping (T) -> [AnyHashable],
        completion: @escaping (Result<(), Error>) -> ()
    ) {
        select { result in
            guard let stored = result.get(ifFailure: completion)?.distinguished(by: selectKeys, mode: .keepLast) else { return }
            
            let matching = findMatchingIndices(of: stored, and: elements, distinguishBy: selectKeys)
            let (existing, new) = elements.partitioned(by: Set(matching.map({ $0.1 })))
            
            if overwrite {
                let (_, toKeep) = stored.partitioned(by: Set(matching.map({ $0.0 })))
                insert(toKeep + existing.distinguished(by: selectKeys, mode: .keepLast) + new, completion)
            } else {
                insert(stored + new, completion)
            }
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
                
                let filtered = stored.filter({ !predicate($0) })
                guard filtered.count < stored.count else {
                    completion(.success(()))
                    return
                }
                
                insert(filtered, completion)
            }
        } else {
            removeAll(ofType: T.self, insert: insert, completion: completion)
        }
    }
    
    private func remove<T, S>(
        where predicate: ((S) -> Bool)?,
        transform: @escaping TransformElement<T, S>,
        select: SelectCollection<T>,
        insert: @escaping InsertCollection<T>,
        completion: @escaping (Result<(), Error>) -> ()
    ) {
        let predicate: ((T) -> Bool)? = {
            if let predicate = predicate {
                return { predicate(transform($0)) }
            } else {
                return nil
            }
        }()
        
        self.remove(where: predicate, select: select, insert: insert, completion: completion)
    }
    
    private func removeAll<T>(ofType type: T.Type, insert: @escaping InsertCollection<T>, completion: @escaping (Result<(), Error>) -> ()) {
        insert([], completion)
    }
    
    private func findMatchingIndices<T>(of first: [T], and second: [T], distinguishBy selectKeys: @escaping (T) -> [AnyHashable]) ->[(Int, Int)] {
        var indices = [Int: [Int]]()
        
        indices.fillWith(first, selectHashables: selectKeys)
        indices.fillWith(second, selectHashables: selectKeys)
        
        return indices.values.filter { $0.count == 2 }.map { ($0[0], $0[1]) }
    }
}

private extension Dictionary where Key == Int {
    mutating func fillWith<T>(_ elements: [T], selectHashables: @escaping (T) -> [AnyHashable]) where Value == Array<Int> {
        elements.enumerated().forEach { (index, element) in
            let hash = selectHashables(element).reduce(0) { (acc, next) in acc &+ next.hashValue }
            self[hash, default: []].append(index)
        }
    }
}
