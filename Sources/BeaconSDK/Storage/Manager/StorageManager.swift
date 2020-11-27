//
//  StorageManager.swift
//  BeaconSDK
//
//  Created by Julia Samol on 25.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
class StorageManager: ExtendedStorage {
    private let storage: ExtendedStorage
    
    init(storage: ExtendedStorage) {
        self.storage = storage
    }
    
    init(storage: Storage) {
        self.storage = storage.extend()
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
        overwrite: Bool = false,
        compareBy predicate: @escaping (Beacon.PeerInfo, Beacon.PeerInfo) -> Bool = { $0 == $1 },
        completion: @escaping (Result<(), Error>) -> ()
    ) {
        storage.add(peers, overwrite: overwrite, compareBy: predicate, completion: completion)
    }
    
    func removePeers(where predicate: ((Beacon.PeerInfo) -> Bool)? = nil, completion: @escaping (Result<(), Error>) -> ()) {
        storage.getPeers { result in
            guard let peers = result.get(ifFailure: completion) else { return }
            let toRemove = peers.filter(predicate)
        
            self.storage.removePeers(where: predicate) { result in
                guard result.isSuccess(otherwise: completion) else { return }
        
                self.removePermissions(
                    where: { permission in toRemove.contains { $0.matches(appMetadata: permission.appMetadata) } },
                    completion: completion
                )
            }
        }
    }
    
    func remove(_ peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Error>) -> ()) {
        removePeers(where: { peers.contains($0) }, completion: completion)
    }
    
    // MARK: AppMetadata
    
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
    
    func getAppMetadata(completion: @escaping (Result<[Beacon.AppMetadata], Error>) -> ()) {
        storage.getAppMetadata(completion: completion)
    }
    
    func set(_ appMetadata: [Beacon.AppMetadata], completion: @escaping (Result<(), Error>) -> ()) {
        storage.set(appMetadata, completion: completion)
    }
    
    // MARK: Permissions
    
    func add(
        _ permissions: [Beacon.PermissionInfo],
        overwrite: Bool = false,
        compareBy predicate: @escaping (Beacon.PermissionInfo, Beacon.PermissionInfo) -> Bool = { $0 == $1 },
        completion: @escaping (Result<(), Error>) -> ()
    ) {
        storage.add(permissions, overwrite: overwrite, compareBy: predicate, completion: completion)
    }
    
    func getPermissions(completion: @escaping (Result<[Beacon.PermissionInfo], Error>) -> ()) {
        storage.getPermissions(completion: completion)
    }
    
    func set(_ permissions: [Beacon.PermissionInfo], completion: @escaping (Result<(), Error>) -> ()) {
        storage.set(permissions, completion: completion)
    }
    
    func removePermissions(where predicate: ((Beacon.PermissionInfo) -> Bool)?, completion: @escaping (Result<(), Error>) -> ()) {
        storage.removePermissions(where: predicate, completion: completion)
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
