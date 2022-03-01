//
//  Storage.swift
//
//
//  Created by Julia Samol on 10.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public protocol Storage {
    
    // MARK: Peers
    
    func getPeers(completion: @escaping (Result<[Beacon.Peer], Error>) -> ())
    func set(_ peers: [Beacon.Peer], completion: @escaping (Result<(), Error>) -> ())
    
    // MARK: AppMetadata
    
    func getAppMetadata<T: AppMetadataProtocol>(completion: @escaping (Result<[T], Error>) -> ())
    func set<T: AppMetadataProtocol>(_ appMetadata: [T], completion: @escaping (Result<(), Error>) -> ())
    
    func getLegacyAppMetadata<T: LegacyAppMetadataProtocol>(completion: @escaping (Result<[T], Error>) -> ())
    func setLegacy<T: LegacyAppMetadataProtocol>(_ appMetadata: [T], completion: @escaping (Result<(), Error>) -> ())
    
    // MARK: Permissions
    
    func getPermissions<T: PermissionProtocol>(completion: @escaping (Result<[T], Error>) -> ())
    func set<T: PermissionProtocol>(_ permissions: [T], completion: @escaping (Result<(), Error>) -> ())
    
    func getLegacyPermissions<T: LegacyPermissionProtocol>(completion: @escaping (Result<[T], Error>) -> ())
    func setLegacy<T: LegacyPermissionProtocol>(_ permissions: [T], completion: @escaping (Result<(), Error>) -> ())
    
    // MARK: SDK
    
    func getSDKVersion(completion: @escaping (Result<String?, Error>) -> ())
    func setSDKVersion(_ version: String, completion: @escaping (Result<(), Error>) -> ())
    
    func getMigrations(completion: @escaping (Result<Set<String>, Error>) -> ())
    func setMigrations(_ migrations: Set<String>, completion: @escaping (Result<(), Error>) -> ())
}

// MARK: Extensions

extension Storage {
    func extend() -> ExtendedStorage {
        DecoratedStorage(storage: self)
    }
}
