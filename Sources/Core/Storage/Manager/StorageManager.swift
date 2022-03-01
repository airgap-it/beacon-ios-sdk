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
    private let blockchainRegistry: BlockchainRegistryProtocol
    private let identifierCreator: IdentifierCreatorProtocol
    
    public private(set) var plugins: [StoragePlugin] = []
    
    init(
        storage: ExtendedStorage,
        secureStorage: SecureStorage,
        blockchainRegistry: BlockchainRegistryProtocol,
        identifierCreator: IdentifierCreatorProtocol
    ) {
        self.storage = storage
        self.secureStorage = secureStorage
        self.blockchainRegistry = blockchainRegistry
        self.identifierCreator = identifierCreator
    }
    
    convenience init(
        storage: Storage,
        secureStorage: SecureStorage,
        blockchainRegistry: BlockchainRegistryProtocol,
        identifierCreator: IdentifierCreatorProtocol
    ) {
        self.init(storage: storage.extend(), secureStorage: secureStorage, blockchainRegistry: blockchainRegistry, identifierCreator: identifierCreator)
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
        
                self.removeAllPermissions(
                    where: { (permission: AnyPermission) in toRemove.contains {
                        let senderID = try? self.identifierCreator.senderID(from: try HexString(from: $0.publicKey))
                        return senderID == permission.senderID
                    } },
                    completion: completion
                )
            }
        }
    }
    
    public func remove(_ peers: [Beacon.Peer], completion: @escaping (Result<(), Swift.Error>) -> ()) {
        removePeers(where: { peers.contains($0) }, completion: completion)
    }
    
    // MARK: AppMetadata
    
    public func getAppMetadata<T: AppMetadataProtocol>(completion: @escaping (Result<[T], Swift.Error>) -> ()) {
        storage.getAppMetadata(completion: completion)
    }
    
    public func set<T: AppMetadataProtocol>(_ appMetadata: [T], completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.set(appMetadata, completion: completion)
    }
    
    public func add<T: AppMetadataProtocol>(
        _ appMetadata: [T],
        overwrite: Bool = false,
        compareBy predicate: @escaping (T, T) -> Bool = { $0 == $1 },
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        storage.add(appMetadata, overwrite: overwrite, compareBy: predicate, completion: completion)
    }
    
    public func findAppMetadata<T: AppMetadataProtocol>(
        where predicate: @escaping (T) -> Bool,
        completion: @escaping (Result<T?, Swift.Error>) -> ()
    ) {
        storage.findAppMetadata(where: predicate, completion: completion)
    }
    
    public func removeAppMetadata<T: AppMetadataProtocol>(where predicate: @escaping ((T) -> Bool), completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.removeAppMetadata(where: predicate, completion: completion)
    }
    
    public func removeAppMetadata<T: AppMetadataProtocol>(ofType type: T.Type, where predicate: ((AnyAppMetadata) -> Bool)? = nil, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.removeAppMetadata(ofType: type, where: predicate, completion: completion)
    }
    
    public func removeAllAppMetadata(where predicate: ((AnyAppMetadata) -> Bool)? = nil, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        let blockchains = blockchainRegistry.getAll()
        blockchains.forEachAsync(body: { $0.storageExtension.removeAppMetadata(where: predicate, completion: $1) }) { results in
            guard results.allSatisfy({ $0.isSuccess }) else {
                let (notRemoved, errors) = results.enumerated()
                    .map { (index, result) in (type(of: blockchains[index]).identifier, result.error) }
                    .filter { (_, error) in error != nil }
                    .unzip()
                
                completion(.failure(Error.removeFromStorageFailed(errors.compactMap({ $0 }), specifiers: notRemoved)))
                
                return
            }
            
            completion(.success(()))
        }
    }
    
    public func remove<T: AppMetadataProtocol>(_ appMetadata: [T], completion: @escaping (Result<(), Swift.Error>) -> ()) {
        removeAppMetadata(where: { appMetadata.contains($0) }, completion: completion)
    }
    
    public func getLegacyAppMetadata<T: LegacyAppMetadataProtocol>(completion: @escaping (Result<[T], Swift.Error>) -> ()) {
        storage.getLegacyAppMetadata(completion: completion)
    }
    
    public func setLegacy<T: LegacyAppMetadataProtocol>(_ appMetadata: [T], completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.setLegacy(appMetadata, completion: completion)
    }
    
    public func removeLegacyAppMetadata<T: LegacyAppMetadataProtocol>(ofType type: T.Type, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.removeLegacyAppMetadata(ofType: type, completion: completion)
    }
    
    // MARK: Permissions
    
    public func getPermissions<T: PermissionProtocol>(completion: @escaping (Result<[T], Swift.Error>) -> ()) {
        storage.getPermissions(completion: completion)
    }
    
    public func set<T: PermissionProtocol>(_ permissions: [T], completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.set(permissions, completion: completion)
    }
    
    public func add<T: PermissionProtocol>(
        _ permissions: [T],
        overwrite: Bool = false,
        compareBy predicate: @escaping (T, T) -> Bool = { $0 == $1 },
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        storage.add(permissions, overwrite: overwrite, compareBy: predicate, completion: completion)
    }
    
    public func findPermissions<T: PermissionProtocol>(
        where predicate: @escaping (T) -> Bool,
        completion: @escaping (Result<T?, Swift.Error>) -> ()
    ) {
        storage.findPermissions(where: predicate, completion: completion)
    }
    
    public func removePermissions<T: PermissionProtocol>(where predicate: @escaping ((T) -> Bool), completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.removePermissions(where: predicate, completion: completion)
    }
    
    public func removePermissions<T: PermissionProtocol>(ofType type: T.Type, where predicate: ((AnyPermission) -> Bool)? = nil, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.removePermissions(ofType: type, where: predicate, completion: completion)
    }
    
    public func removeAllPermissions(where predicate: ((AnyPermission) -> Bool)? = nil, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        let blockchains = blockchainRegistry.getAll()
        blockchains.forEachAsync(body: { $0.storageExtension.removePermissions(where: predicate, completion: $1) }) { results in
            guard results.allSatisfy({ $0.isSuccess }) else {
                let (notRemoved, errors) = results.enumerated()
                    .map { (index, result) in (type(of: blockchains[index]).identifier, result.error) }
                    .filter { (_, error) in error != nil }
                    .unzip()
                
                completion(.failure(Error.removeFromStorageFailed(errors.compactMap({ $0 }), specifiers: notRemoved)))
                
                return
            }
            
            completion(.success(()))
        }
    }
    
    public func remove<T: PermissionProtocol>(_ permissions: [T], completion: @escaping (Result<(), Swift.Error>) -> ()) {
        removePermissions(where: { permissions.contains($0) }, completion: completion)
    }
    
    public func getLegacyPermissions<T: LegacyPermissionProtocol>(completion: @escaping (Result<[T], Swift.Error>) -> ()) {
        storage.getLegacyPermissions(completion: completion)
    }
    
    public func setLegacy<T: LegacyPermissionProtocol>(_ permissions: [T], completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.setLegacy(permissions, completion: completion)
    }
    
    public func removeLegacyPermissions<T>(ofType type: T.Type, completion: @escaping (Result<(), Swift.Error>) -> ()) where T : LegacyPermissionProtocol {
        storage.removeLegacyPermissions(ofType: type, completion: completion)
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
        case removeFromStorageFailed(_ errors: [Swift.Error], specifiers: [String] = [])
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
