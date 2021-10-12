//
//  UserDefaultsStorage.swift
//
//
//  Created by Julia Samol on 10.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public struct UserDefaultsStorage: Storage {
    
    private let userDefaults: UserDefaults
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: Peers
    
    public func getPeers(completion: @escaping (Result<[Beacon.Peer], Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.get([Beacon.Peer].self, forKey: .peers) ?? []
        }
    }
    
    public func set(_ peers: [Beacon.Peer], completion: @escaping (Result<(), Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.set(peers, forKey: .peers)
        }
    }
    
    // MARK: AppMetadata
    
    public func getAppMetadata(completion: @escaping (Result<[Beacon.AppMetadata], Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.get([Beacon.AppMetadata].self, forKey: .appMetadata) ?? []
        }
    }
    
    public func set(_ appMetadata: [Beacon.AppMetadata], completion: @escaping (Result<(), Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.set(appMetadata, forKey: .appMetadata)
        }
    }
    
    // MARK: Permissions
    
    public func getPermissions<T: PermissionProtocol & Codable>(completion: @escaping (Result<[T], Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.get([T].self, forKey: .permissions) ?? []
        }
    }
    
    public func set<T: PermissionProtocol & Codable>(_ permissions: [T], completion: @escaping (Result<(), Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.set(permissions, forKey: .permissions)
        }
    }
    
    // MARK: SDK
    
    public func getSDKVersion(completion: @escaping (Result<String?, Error>) -> ()) {
        let version = userDefaults.string(forKey: .sdkVersion)
        completion(.success(version))
    }
    
    public func setSDKVersion(_ version: String, completion: @escaping (Result<(), Error>) -> ()) {
        userDefaults.set(version, forKey: .sdkVersion)
        completion(.success(()))
    }
    
    public func getMigrations(completion: @escaping (Result<Set<String>, Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.get(Set<String>.self, forKey: .migrations) ?? []
        }
    }
    
    public func setMigrations(_ migrations: Set<String>, completion: @escaping (Result<(), Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.set(migrations, forKey: .migrations)
        }
    }
    
    // MARK: Types
    
    enum Key: String {
        case peers
        case appMetadata
        case permissions
        case matrixRelayServer
        case matrixChannels
        case matrixSyncToken
        case matrixRooms
        case sdkVersion
        case migrations
    }
}

// MARK: Extensions

private extension UserDefaults {
    func set(_ value: String, forKey key: UserDefaultsStorage.Key) {
        set(value, forKey: key.rawValue)
    }
    
    func set<T: Codable>(_ value: T, forKey key: UserDefaultsStorage.Key) throws {
        let propertyListEncoder = PropertyListEncoder()
        set(try propertyListEncoder.encode(value), forKey: key.rawValue)
    }
    
    func string(forKey key: UserDefaultsStorage.Key) -> String? {
        string(forKey: key.rawValue)
    }
    
    func get<T: Codable>(_ type: T.Type, forKey key: UserDefaultsStorage.Key) throws -> T? {
        let propertyListDecoder = PropertyListDecoder()
        if let data = data(forKey: key.rawValue) {
            return try propertyListDecoder.decode(type, from: data)
        } else {
            return nil
        }
    }
    
    func removeObject(forKey key: UserDefaultsStorage.Key) {
        removeObject(forKey: key.rawValue)
    }
}
