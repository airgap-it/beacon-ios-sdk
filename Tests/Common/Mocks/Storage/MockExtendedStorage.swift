//
//  MockExtendedStorage.swift
//  
//
//  Created by Julia Samol on 18.05.22.
//

import Foundation
@testable import BeaconCore

public class MockExtendedStorage : ExtendedStorage {
    private let storage: ExtendedStorage
    
    public init(storage: MockStorage = .init()) {
        self.storage = storage.extend()
    }
    
    // MARK: Peers
    
    public func getPeers(completion: @escaping (Result<[Beacon.Peer], Error>) -> ()) {
        storage.getPeers(completion: completion)
    }
    
    public func set(_ peers: [Beacon.Peer], completion: @escaping (Result<(), Error>) -> ()) {
        storage.set(peers, completion: completion)
    }
    
    public func add(
        _ peers: [Beacon.Peer],
        overwrite: Bool,
        distinguishBy selectKeys: @escaping (Beacon.Peer) -> [AnyHashable],
        completion: @escaping (Result<(), Error>) -> ()
    ) {
        storage.add(peers, overwrite: overwrite, distinguishBy: selectKeys, completion: completion)
    }
    
    public func findPeers(where predicate: @escaping (Beacon.Peer) -> Bool, completion: @escaping (Result<Beacon.Peer?, Error>) -> ()) {
        storage.findPeers(where: predicate, completion: completion)
    }
    
    public func removePeers(where predicate: ((Beacon.Peer) -> Bool)?, completion: @escaping (Result<(), Error>) -> ()) {
        storage.removePeers(where: predicate, completion: completion)
    }
    
    // MARK: AppMetadata
    
    public func getAppMetadata<T>(completion: @escaping (Result<[T], Error>) -> ()) where T : AppMetadataProtocol {
        storage.getAppMetadata(completion: completion)
    }
    
    public func set<T>(_ appMetadata: [T], completion: @escaping (Result<(), Error>) -> ()) where T : AppMetadataProtocol {
        storage.set(appMetadata, completion: completion)
    }
    
    public func add<T>(
        _ appMetadata: [T],
        overwrite: Bool,
        distinguishBy selectKeys: @escaping (T) -> [AnyHashable],
        completion: @escaping (Result<(), Error>) -> ()
    ) where T : AppMetadataProtocol {
        storage.add(appMetadata, overwrite: overwrite, distinguishBy: selectKeys, completion: completion)
    }
    
    public func findAppMetadata<T>(where predicate: @escaping (T) -> Bool, completion: @escaping (Result<T?, Error>) -> ()) where T : AppMetadataProtocol {
        storage.findAppMetadata(where: predicate, completion: completion)
    }
    
    public func removeAppMetadata<T>(where predicate: @escaping ((T) -> Bool), completion: @escaping (Result<(), Error>) -> ()) where T : AppMetadataProtocol {
        storage.removeAppMetadata(where: predicate, completion: completion)
    }
    
    public func removeAppMetadata<T>(ofType type: T.Type, where predicate: ((AnyAppMetadata) -> Bool)?, completion: @escaping (Result<(), Error>) -> ()) where T : AppMetadataProtocol {
        storage.removeAppMetadata(ofType: type, where: predicate, completion: completion)
    }
    
    public func getLegacyAppMetadata<T>(completion: @escaping (Result<[T], Error>) -> ()) where T : LegacyAppMetadataProtocol {
        storage.getLegacyAppMetadata(completion: completion)
    }
    
    public func setLegacy<T>(_ appMetadata: [T], completion: @escaping (Result<(), Error>) -> ()) where T : LegacyAppMetadataProtocol {
        storage.setLegacy(appMetadata, completion: completion)
    }
    
    public func removeLegacyAppMetadata<T>(ofType type: T.Type, completion: @escaping (Result<(), Error>) -> ()) where T : LegacyAppMetadataProtocol {
        storage.removeLegacyAppMetadata(ofType: type, completion: completion)
    }
    
    // MARK: Permissions
    
    public func getPermissions<T>(completion: @escaping (Result<[T], Error>) -> ()) where T : PermissionProtocol {
        storage.getPermissions(completion: completion)
    }
    
    public func set<T>(_ permissions: [T], completion: @escaping (Result<(), Error>) -> ()) where T : PermissionProtocol {
        storage.set(permissions, completion: completion)
    }
    
    public func add<T>(
        _ permissions: [T],
        overwrite: Bool,
        distinguishBy selectKeys: @escaping (T) -> [AnyHashable],
        completion: @escaping (Result<(), Error>) -> ()
    ) where T : PermissionProtocol {
        storage.add(permissions, overwrite: overwrite, distinguishBy: selectKeys, completion: completion)
    }
    
    public func findPermissions<T>(where predicate: @escaping (T) -> Bool, completion: @escaping (Result<T?, Error>) -> ()) where T : PermissionProtocol {
        storage.findPermissions(where: predicate, completion: completion)
    }
    
    public func removePermissions<T>(where predicate: @escaping ((T) -> Bool), completion: @escaping (Result<(), Error>) -> ()) where T : PermissionProtocol {
        storage.removePermissions(where: predicate, completion: completion)
    }
    
    public func removePermissions<T>(ofType type: T.Type, where predicate: ((AnyPermission) -> Bool)?, completion: @escaping (Result<(), Error>) -> ()) where T : PermissionProtocol {
        storage.removePermissions(ofType: type, where: predicate, completion: completion)
    }
    
    public func getLegacyPermissions<T>(completion: @escaping (Result<[T], Error>) -> ()) where T : LegacyPermissionProtocol {
        storage.getLegacyPermissions(completion: completion)
    }
    
    public func setLegacy<T>(_ permissions: [T], completion: @escaping (Result<(), Error>) -> ()) where T : LegacyPermissionProtocol {
        storage.setLegacy(permissions, completion: completion)
    }
    
    public func removeLegacyPermissions<T>(ofType type: T.Type, completion: @escaping (Result<(), Error>) -> ()) where T : LegacyPermissionProtocol {
        storage.removeLegacyPermissions(ofType: type, completion: completion)
    }
    
    // MARK: SDK
    
    public func getSDKVersion(completion: @escaping (Result<String?, Error>) -> ()) {
        storage.getSDKVersion(completion: completion)
    }
    
    public func setSDKVersion(_ version: String, completion: @escaping (Result<(), Error>) -> ()) {
        storage.setSDKVersion(version, completion: completion)
    }
    
    public func getMigrations(completion: @escaping (Result<Set<String>, Error>) -> ()) {
        storage.getMigrations(completion: completion)
    }
    
    public func setMigrations(_ migrations: Set<String>, completion: @escaping (Result<(), Error>) -> ()) {
        storage.setMigrations(migrations, completion: completion)
    }
    
    public func addMigrations(_ migrations: Set<String>, completion: @escaping (Result<(), Error>) -> ()) {
        storage.addMigrations(migrations, completion: completion)
    }
}
