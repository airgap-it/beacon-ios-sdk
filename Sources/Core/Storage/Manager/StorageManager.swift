//
//  StorageManager.swift
//
//
//  Created by Julia Samol on 25.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
public class StorageManager: ExtendedStorage, SecureStorage {
    private let storage: ExtendedStorage
    private let secureStorage: SecureStorage
    private let identifierCreator: IdentifierCreatorProtocol
    
    public private(set) var plugins: [StoragePlugin] = []
    
    init(storage: ExtendedStorage, secureStorage: SecureStorage, identifierCreator: IdentifierCreatorProtocol) {
        self.storage = storage
        self.secureStorage = secureStorage
        self.identifierCreator = identifierCreator
    }
    
    convenience init(storage: Storage, secureStorage: SecureStorage, identifierCreator: IdentifierCreatorProtocol) {
        self.init(storage: storage.extend(), secureStorage: secureStorage, identifierCreator: identifierCreator)
    }
    
    // MAKR: Plugins
    
    public func addPlugins(_ plugins: [StoragePlugin]) {
        self.plugins.append(contentsOf: plugins)
    }
    
    // MARK: Peers
    
    public func getPeers(completion: @escaping (Result<[Beacon.Peer], Swift.Error>) -> ()) {
        storage.getPeers(completion: completion)
    }
    
    public func set(_ peers: [Beacon.Peer], completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.set(peers, completion: completion)
    }
    
    public func add(
        _ peers: [Beacon.Peer],
        overwrite: Bool = false,
        compareBy predicate: @escaping (Beacon.Peer, Beacon.Peer) -> Bool = { $0 == $1 },
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        storage.add(peers, overwrite: overwrite, compareBy: predicate, completion: completion)
    }
    
    public func findPeers(where predicate: @escaping (Beacon.Peer) -> Bool, completion: @escaping (Result<Beacon.Peer?, Swift.Error>) -> ()) {
        storage.findPeers(where: predicate, completion: completion)
    }
    
    public func removePeers(where predicate: ((Beacon.Peer) -> Bool)? = nil, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.getPeers { result in
            guard let peers = result.get(ifFailure: completion) else { return }
            let toRemove = peers.filter(predicate)
        
            self.storage.removePeers(where: predicate) { result in
                guard result.isSuccess(else: completion) else { return }
        
                self.removePermissions(
                    where: { (permission: AnyPermission) in toRemove.contains { $0.matches(appMetadata: permission.appMetadata, using: self.identifierCreator) } },
                    completion: completion
                )
            }
        }
    }
    
    public func remove(_ peers: [Beacon.Peer], completion: @escaping (Result<(), Swift.Error>) -> ()) {
        removePeers(where: { peers.contains($0) }, completion: completion)
    }
    
    // MARK: AppMetadata
    
    public func getAppMetadata(completion: @escaping (Result<[Beacon.AppMetadata], Swift.Error>) -> ()) {
        storage.getAppMetadata(completion: completion)
    }
    
    public func set(_ appMetadata: [Beacon.AppMetadata], completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.set(appMetadata, completion: completion)
    }
    
    public func add(
        _ appMetadata: [Beacon.AppMetadata],
        overwrite: Bool = false,
        compareBy predicate: @escaping (Beacon.AppMetadata, Beacon.AppMetadata) -> Bool = { $0 == $1 },
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        storage.add(appMetadata, overwrite: overwrite, compareBy: predicate, completion: completion)
    }
    
    public func findAppMetadata(
        where predicate: @escaping (Beacon.AppMetadata) -> Bool,
        completion: @escaping (Result<Beacon.AppMetadata?, Swift.Error>) -> ()
    ) {
        storage.findAppMetadata(where: predicate, completion: completion)
    }
    
    public func removeAppMetadata(where predicate: ((Beacon.AppMetadata) -> Bool)? = nil, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.removeAppMetadata(where: predicate, completion: completion)
    }
    
    public func remove(_ appMetadata: [Beacon.AppMetadata], completion: @escaping (Result<(), Swift.Error>) -> ()) {
        removeAppMetadata(where: { appMetadata.contains($0) }, completion: completion)
    }
    
    // MARK: Permissions
    
    public func getPermissions<T: PermissionProtocol & Codable>(completion: @escaping (Result<[T], Swift.Error>) -> ()) {
        storage.getPermissions(completion: completion)
    }
    
    public func set<T: PermissionProtocol & Codable>(_ permissions: [T], completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.set(permissions, completion: completion)
    }
    
    public func add<T: PermissionProtocol & Codable & Equatable>(
        _ permissions: [T],
        overwrite: Bool = false,
        compareBy predicate: @escaping (T, T) -> Bool = { $0 == $1 },
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        storage.add(permissions, overwrite: overwrite, compareBy: predicate, completion: completion)
    }
    
    public func findPermissions<T: PermissionProtocol & Codable>(
        where predicate: @escaping (T) -> Bool,
        completion: @escaping (Result<T?, Swift.Error>) -> ()
    ) {
        storage.findPermissions(where: predicate, completion: completion)
    }
    
    public func removePermissions(where predicate: ((AnyPermission) -> Bool)? = nil, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.removePermissions(where: predicate, completion: completion)
    }
    
    public func removePermissions<T: PermissionProtocol & Codable>(where predicate: ((T) -> Bool)? = nil, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.removePermissions(where: predicate, completion: completion)
    }
    
    public func remove<T: PermissionProtocol & Codable & Equatable>(_ permissions: [T], completion: @escaping (Result<(), Swift.Error>) -> ()) {
        removePermissions(where: { permissions.contains($0) }, completion: completion)
    }
    
    // MARK: SDK
    
    public func getSDKSecretSeed(completion: @escaping (Result<String?, Swift.Error>) -> ()) {
        secureStorage.getSDKSecretSeed(completion: completion)
    }
    
    public func setSDKSecretSeed(_ seed: String, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        secureStorage.setSDKSecretSeed(seed, completion: completion)
    }
    
    public func getSDKVersion(completion: @escaping (Result<String?, Swift.Error>) -> ()) {
        storage.getSDKVersion(completion: completion)
    }
    
    public func setSDKVersion(_ version: String, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.setSDKVersion(version, completion: completion)
    }
    
    public func getMigrations(completion: @escaping (Result<Set<String>, Swift.Error>) -> ()) {
        storage.getMigrations(completion: completion)
    }
    
    public func setMigrations(_ migrations: Set<String>, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.setMigrations(migrations, completion: completion)
    }
    
    public func addMigrations(_ migrations: Set<String>, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.addMigrations(migrations, completion: completion)
    }
    
    // MARK: Types
    
    public enum Error: Swift.Error {
        case missingPlugin(String)
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
