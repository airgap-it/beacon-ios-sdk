//
//  MockStorage.swift
//  Mocks
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

@testable import BeaconCore

public class MockStorage: Storage {
    public var peers: [Beacon.Peer] = []
    
    public var appMetadata: [MockBlockchain.AppMetadata] = []
    public var legacyAppMetadata: [AnyLegacyAppMetadata] = []
    
    public var permissions: [MockBlockchain.Permission] = []
    public var legacyPermissions: [AnyLegacyPermission] = []
    
    public var matrixRelayServer: String?
    public var matrixChannels: [String: String] = [:]
    public var matrixSyncToken: String?
    
    public var sdkVersion: String?
    public var migrations: Set<String> = []
    
    public init() {}
    
    // MARK: Peers
    
    public func getPeers(completion: @escaping (Result<[Beacon.Peer], Error>) -> ()) {
        completion(.success(peers))
    }
    
    public func set(_ peers: [Beacon.Peer], completion: @escaping (Result<(), Error>) -> ()) {
        self.peers = peers
        completion(.success(()))
    }
    
    // MARK: AppMetadata
    
    public func getAppMetadata<T: AppMetadataProtocol>(completion: @escaping (Result<[T], Error>) -> ()) {
        completion(.success(appMetadata.compactMap({ $0 as? T })))
    }
    
    public func set<T: AppMetadataProtocol>(_ appMetadata: [T], completion: @escaping (Result<(), Error>) -> ()) {
        self.appMetadata = appMetadata.map { MockBlockchain.AppMetadata($0) }
        completion(.success(()))
    }
    
    public func getLegacyAppMetadata<T: LegacyAppMetadataProtocol>(completion: @escaping (Result<[T], Error>) -> ()) {
        completion(.success(legacyAppMetadata.compactMap({ $0 as? T })))
    }
    
    public func setLegacy<T: LegacyAppMetadataProtocol>(_ appMetadata: [T], completion: @escaping (Result<(), Error>) -> ()) {
        self.legacyAppMetadata = appMetadata.map { AnyLegacyAppMetadata($0) }
        completion(.success(()))
    }
    
    // MARK: Permissions
    
    public func getPermissions<T: PermissionProtocol>(completion: @escaping (Result<[T], Error>) -> ()) {
        completion(.success(permissions.compactMap({ $0 as? T })))
    }
    
    public func set<T: PermissionProtocol>(_ permissions: [T], completion: @escaping (Result<(), Error>) -> ()) {
        self.permissions = permissions.map { MockBlockchain.Permission($0) }
        completion(.success(()))
    }
    
    public func getLegacyPermissions<T: LegacyPermissionProtocol>(completion: @escaping (Result<[T], Error>) -> ()) {
        completion(.success(legacyPermissions.compactMap({ $0 as? T })))
    }
    
    public func setLegacy<T>(_ permissions: [T], completion: @escaping (Result<(), Error>) -> ()) where T : LegacyPermissionProtocol {
        self.legacyPermissions = permissions.map { AnyLegacyPermission($0) }
        completion(.success(()))
    }
    
    // MARK: SDK
    
    public func getSDKVersion(completion: @escaping (Result<String?, Error>) -> ()) {
        completion(.success(sdkVersion))
    }
    
    public func setSDKVersion(_ version: String, completion: @escaping (Result<(), Error>) -> ()) {
        sdkVersion = version
        completion(.success(()))
    }
    
    public func getMigrations(completion: @escaping (Result<Set<String>, Error>) -> ()) {
        completion(.success(migrations))
    }
    
    public func setMigrations(_ migrations: Set<String>, completion: @escaping (Result<(), Error>) -> ()) {
        self.migrations = migrations
        completion(.success(()))
    }
}
