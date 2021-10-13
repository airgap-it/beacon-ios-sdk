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
    public var appMetadata: [Beacon.AppMetadata] = []
    public var permissions: [PermissionProtocol] = []
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
    
    public func getAppMetadata(completion: @escaping (Result<[Beacon.AppMetadata], Error>) -> ()) {
        completion(.success(appMetadata))
    }
    
    public func set(_ appMetadata: [Beacon.AppMetadata], completion: @escaping (Result<(), Error>) -> ()) {
        self.appMetadata = appMetadata
        completion(.success(()))
    }
    
    // MARK: Permissions
    
    public func getPermissions<T: PermissionProtocol & Codable>(completion: @escaping (Result<[T], Error>) -> ()) {
        completion(.success(permissions.compactMap({ $0 as? T })))
    }
    
    public func set<T: PermissionProtocol & Codable>(_ permissions: [T], completion: @escaping (Result<(), Error>) -> ()) {
        self.permissions = permissions
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