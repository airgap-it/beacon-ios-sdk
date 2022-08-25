//
//  DecoratedDAppClientStorage.swift
//  
//
//  Created by Julia Samol on 11.08.22.
//

import Foundation
import BeaconCore

struct DecoratedDAppClientStorage: ExtendedDAppClientStorage {
    private let extendedStoragePlugin: ExtendedDAppClientStoragePlugin
    private let extendedStorage: ExtendedStorage
    
    init(storage: DAppClientStorage) {
        self.extendedStoragePlugin = DecoratedDAppClientStoragePlugin(storagePlugin: storage)
        self.extendedStorage = DecoratedStorage(storage: storage)
    }
    
    // MARK: Account
    
    func getActiveAccount(completion: @escaping (Result<PairedAccount?, Error>) -> ()) {
        extendedStoragePlugin.getActiveAccount(completion: completion)
    }
    
    func setActiveAccount(_ account: PairedAccount?, completion: @escaping (Result<(), Error>) -> ()) {
        extendedStoragePlugin.setActiveAccount(account, completion: completion)
    }
    
    
    func removeActiveAccount(completion: @escaping (Result<(), Error>) -> ()) {
        extendedStoragePlugin.removeActiveAccount(completion: completion)
    }
    
    // MARK: Active Peer
    
    func getActivePeer(completion: @escaping (Result<String?, Error>) -> ()) {
        extendedStoragePlugin.getActivePeer(completion: completion)
    }
    
    func setActivePeer(_ peerID: String?, completion: @escaping (Result<(), Error>) -> ()) {
        extendedStoragePlugin.setActivePeer(peerID, completion: completion)
    }
    
    func removeActivePeer(completion: @escaping (Result<(), Error>) -> ()) {
        extendedStoragePlugin.removeActivePeer(completion: completion)
    }
    
    // MARK: Peers
    
    func getPeers(completion: @escaping (Result<[Beacon.Peer], Error>) -> ()) {
        extendedStorage.getPeers(completion: completion)
    }
    
    func set(_ peers: [Beacon.Peer], completion: @escaping (Result<(), Error>) -> ()) {
        extendedStorage.set(peers, completion: completion)
    }
    
    func add(_ peers: [Beacon.Peer], overwrite: Bool, distinguishBy selectKeys: @escaping (Beacon.Peer) -> [AnyHashable], completion: @escaping (Result<(), Error>) -> ()) {
        extendedStorage.add(peers, overwrite: overwrite, distinguishBy: selectKeys, completion: completion)
    }
    
    func findPeers(where predicate: @escaping (Beacon.Peer) -> Bool, completion: @escaping (Result<Beacon.Peer?, Error>) -> ()) {
        extendedStorage.findPeers(where: predicate, completion: completion)
    }
    
    func removePeers(where predicate: ((Beacon.Peer) -> Bool)?, completion: @escaping (Result<(), Error>) -> ()) {
        extendedStorage.removePeers(where: predicate, completion: completion)
    }
    
    // MARK: AppMetadata
    
    func getAppMetadata<T>(completion: @escaping (Result<[T], Error>) -> ()) where T : AppMetadataProtocol {
        extendedStorage.getAppMetadata(completion: completion)
    }
    
    func set<T>(_ appMetadata: [T], completion: @escaping (Result<(), Error>) -> ()) where T : AppMetadataProtocol {
        extendedStorage.set(appMetadata, completion: completion)
    }
    
    func getLegacyAppMetadata<T>(completion: @escaping (Result<[T], Error>) -> ()) where T : LegacyAppMetadataProtocol {
        extendedStorage.getLegacyAppMetadata(completion: completion)
    }
    
    func setLegacy<T>(_ appMetadata: [T], completion: @escaping (Result<(), Error>) -> ()) where T : LegacyAppMetadataProtocol {
        extendedStorage.setLegacy(appMetadata, completion: completion)
    }
    
    func add<T>(_ appMetadata: [T], overwrite: Bool, distinguishBy selectKeys: @escaping (T) -> [AnyHashable], completion: @escaping (Result<(), Error>) -> ()) where T : AppMetadataProtocol {
        extendedStorage.add(appMetadata, overwrite: overwrite, distinguishBy: selectKeys, completion: completion)
    }
    
    func findAppMetadata<T>(where predicate: @escaping (T) -> Bool, completion: @escaping (Result<T?, Error>) -> ()) where T : AppMetadataProtocol {
        extendedStorage.findAppMetadata(where: predicate, completion: completion)
    }
    
    func removeAppMetadata<T>(where predicate: @escaping ((T) -> Bool), completion: @escaping (Result<(), Error>) -> ()) where T : AppMetadataProtocol {
        extendedStorage.removeAppMetadata(where: predicate, completion: completion)
    }
    
    func removeAppMetadata<T>(ofType type: T.Type, where predicate: ((AnyAppMetadata) -> Bool)?, completion: @escaping (Result<(), Error>) -> ()) where T : AppMetadataProtocol {
        extendedStorage.removeAppMetadata(ofType: type, where: predicate, completion: completion)
    }
    
    func removeLegacyAppMetadata<T>(ofType type: T.Type, completion: @escaping (Result<(), Error>) -> ()) where T : LegacyAppMetadataProtocol {
        extendedStorage.removeLegacyAppMetadata(ofType: type, completion: completion)
    }
    
    // MARK: Permissions
    
    func getPermissions<T>(completion: @escaping (Result<[T], Error>) -> ()) where T : PermissionProtocol {
        extendedStorage.getPermissions(completion: completion)
    }
    
    func set<T>(_ permissions: [T], completion: @escaping (Result<(), Error>) -> ()) where T : PermissionProtocol {
        extendedStorage.set(permissions, completion: completion)
    }
    
    func getLegacyPermissions<T>(completion: @escaping (Result<[T], Error>) -> ()) where T : LegacyPermissionProtocol {
        extendedStorage.getLegacyPermissions(completion: completion)
    }
    
    func setLegacy<T>(_ permissions: [T], completion: @escaping (Result<(), Error>) -> ()) where T : LegacyPermissionProtocol {
        extendedStorage.setLegacy(permissions, completion: completion)
    }
    
    func add<T>(_ permissions: [T], overwrite: Bool, distinguishBy selectKeys: @escaping (T) -> [AnyHashable], completion: @escaping (Result<(), Error>) -> ()) where T : PermissionProtocol {
        extendedStorage.add(permissions, overwrite: overwrite, distinguishBy: selectKeys, completion: completion)
    }
    
    func findPermissions<T>(where predicate: @escaping (T) -> Bool, completion: @escaping (Result<T?, Error>) -> ()) where T : PermissionProtocol {
        extendedStorage.findPermissions(where: predicate, completion: completion)
    }
    
    func removePermissions<T>(where predicate: @escaping ((T) -> Bool), completion: @escaping (Result<(), Error>) -> ()) where T : PermissionProtocol {
        extendedStorage.removePermissions(where: predicate, completion: completion)
    }
    
    func removePermissions<T>(ofType type: T.Type, where predicate: ((AnyPermission) -> Bool)?, completion: @escaping (Result<(), Error>) -> ()) where T : PermissionProtocol {
        extendedStorage.removePermissions(ofType: type, where: predicate, completion: completion)
    }
    
    func removeLegacyPermissions<T>(ofType type: T.Type, completion: @escaping (Result<(), Error>) -> ()) where T : LegacyPermissionProtocol {
        extendedStorage.removeLegacyPermissions(ofType: type, completion: completion)
    }
    
    // MARK: SDK
    
    func getSDKVersion(completion: @escaping (Result<String?, Error>) -> ()) {
        extendedStorage.getSDKVersion(completion: completion)
    }
    
    func setSDKVersion(_ version: String, completion: @escaping (Result<(), Error>) -> ()) {
        extendedStorage.setSDKVersion(version, completion: completion)
    }
    
    func getMigrations(completion: @escaping (Result<Set<String>, Error>) -> ()) {
        extendedStorage.getMigrations(completion: completion)
    }
    
    func setMigrations(_ migrations: Set<String>, completion: @escaping (Result<(), Error>) -> ()) {
        extendedStorage.setMigrations(migrations, completion: completion)
    }
    
    func addMigrations(_ migrations: Set<String>, completion: @escaping (Result<(), Error>) -> ()) {
        extendedStorage.addMigrations(migrations, completion: completion)
    }
}
