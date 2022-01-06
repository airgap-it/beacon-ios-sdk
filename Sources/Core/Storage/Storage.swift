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
    
    func getAppMetadata<T: AppMetadataProtocol & Codable>(completion: @escaping (Result<[T], Error>) -> ())
    func set<T: AppMetadataProtocol & Codable>(_ appMetadata: [T], completion: @escaping (Result<(), Error>) -> ())
    
    // MARK: Permissions
    
    func getPermissions<T: PermissionProtocol & Codable>(completion: @escaping (Result<[T], Error>) -> ())
    func set<T: PermissionProtocol & Codable>(_ permissions: [T], completion: @escaping (Result<(), Error>) -> ())
    
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
