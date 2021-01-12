//
//  StorageManager.swift
//  BeaconSDK
//
//  Created by Julia Samol on 25.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
class StorageManager: ExtendedStorage, SecureStorage {
    private let storage: ExtendedStorage
    private let secureStorage: SecureStorage
    private let accountUtils: AccountUtilsProtocol
    
    init(storage: ExtendedStorage, secureStorage: SecureStorage, accountUtils: AccountUtilsProtocol) {
        self.storage = storage
        self.secureStorage = secureStorage
        self.accountUtils = accountUtils
    }
    
    convenience init(storage: Storage, secureStorage: SecureStorage, accountUtils: AccountUtilsProtocol) {
        self.init(storage: storage.extend(), secureStorage: secureStorage, accountUtils: accountUtils)
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
        overwrite: Bool = false,
        compareBy predicate: @escaping (Beacon.Peer, Beacon.Peer) -> Bool = { $0 == $1 },
        completion: @escaping (Result<(), Error>) -> ()
    ) {
        storage.add(peers, overwrite: overwrite, compareBy: predicate, completion: completion)
    }
    
    func findPeers(where predicate: @escaping (Beacon.Peer) -> Bool, completion: @escaping (Result<Beacon.Peer?, Error>) -> ()) {
        storage.findPeers(where: predicate, completion: completion)
    }
    
    func removePeers(where predicate: ((Beacon.Peer) -> Bool)? = nil, completion: @escaping (Result<(), Error>) -> ()) {
        storage.getPeers { result in
            guard let peers = result.get(ifFailure: completion) else { return }
            let toRemove = peers.filter(predicate)
        
            self.storage.removePeers(where: predicate) { result in
                guard result.isSuccess(else: completion) else { return }
        
                self.removePermissions(
                    where: { permission in toRemove.contains { $0.matches(appMetadata: permission.appMetadata, using: self.accountUtils) } },
                    completion: completion
                )
            }
        }
    }
    
    func remove(_ peers: [Beacon.Peer], completion: @escaping (Result<(), Error>) -> ()) {
        removePeers(where: { peers.contains($0) }, completion: completion)
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
        overwrite: Bool = false,
        compareBy predicate: @escaping (Beacon.AppMetadata, Beacon.AppMetadata) -> Bool = { $0 == $1 },
        completion: @escaping (Result<(), Error>) -> ()
    ) {
        storage.add(appMetadata, overwrite: overwrite, compareBy: predicate, completion: completion)
    }
    
    func findAppMetadata(
        where predicate: @escaping (Beacon.AppMetadata) -> Bool,
        completion: @escaping (Result<Beacon.AppMetadata?, Error>) -> ()
    ) {
        storage.findAppMetadata(where: predicate, completion: completion)
    }
    
    func removeAppMetadata(where predicate: ((Beacon.AppMetadata) -> Bool)? = nil, completion: @escaping (Result<(), Error>) -> ()) {
        storage.removeAppMetadata(where: predicate, completion: completion)
    }
    
    func remove(_ appMetadata: [Beacon.AppMetadata], completion: @escaping (Result<(), Error>) -> ()) {
        removeAppMetadata(where: { appMetadata.contains($0) }, completion: completion)
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
        overwrite: Bool = false,
        compareBy predicate: @escaping (Beacon.Permission, Beacon.Permission) -> Bool = { $0 == $1 },
        completion: @escaping (Result<(), Error>) -> ()
    ) {
        storage.add(permissions, overwrite: overwrite, compareBy: predicate, completion: completion)
    }
    
    func findPermissions(
        where predicate: @escaping (Beacon.Permission) -> Bool,
        completion: @escaping (Result<Beacon.Permission?, Error>) -> ()
    ) {
        storage.findPermissions(where: predicate, completion: completion)
    }
    
    func removePermissions(where predicate: ((Beacon.Permission) -> Bool)? = nil, completion: @escaping (Result<(), Error>) -> ()) {
        storage.removePermissions(where: predicate, completion: completion)
    }
    
    func remove(_ permissions: [Beacon.Permission], completion: @escaping (Result<(), Error>) -> ()) {
        removePermissions(where: { permissions.contains($0) }, completion: completion)
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
        secureStorage.getSDKSecretSeed(completion: completion)
    }
    
    func setSDKSecretSeed(_ seed: String, completion: @escaping (Result<(), Error>) -> ()) {
        secureStorage.setSDKSecretSeed(seed, completion: completion)
    }
    
    func getSDKVersion(completion: @escaping (Result<String?, Error>) -> ()) {
        storage.getSDKVersion(completion: completion)
    }
    
    func setSDKVersion(_ version: String, completion: @escaping (Result<(), Error>) -> ()) {
        storage.setSDKVersion(version, completion: completion)
    }
}

// MARK: Extensions

private extension Array {
    
    func filter(_ isIncluded: ((Element) -> Bool)?) -> [Element] {
        if let isIncluded = isIncluded {
            return filter(isIncluded)
        } else {
            return self
        }
    }
}
