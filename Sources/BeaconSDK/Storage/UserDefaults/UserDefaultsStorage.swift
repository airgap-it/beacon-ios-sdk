//
//  UserDefaultsStorage.swift
//  BeaconSDK
//
//  Created by Julia Samol on 10.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

class UserDefaultsStorage: Storage {
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: Peers
    
    func getPeers(completion: @escaping (Result<[Beacon.Peer], Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.get([Beacon.Peer].self, forKey: .peers) ?? []
        }
    }
    
    func set(_ peers: [Beacon.Peer], completion: @escaping (Result<(), Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.set(peers, forKey: .peers)
        }
    }
    
    // MARK: AppMetadata
    
    func getAppMetadata(completion: @escaping (Result<[Beacon.AppMetadata], Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.get([Beacon.AppMetadata].self, forKey: .appMetadata) ?? []
        }
    }
    
    func set(_ appMetadata: [Beacon.AppMetadata], completion: @escaping (Result<(), Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.set(appMetadata, forKey: .appMetadata)
        }
    }
    
    // MARK: Permissions
    
    func getPermissions(completion: @escaping (Result<[Beacon.Permission], Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.get([Beacon.Permission].self, forKey: .permissions) ?? []
        }
    }
    
    func set(_ permissions: [Beacon.Permission], completion: @escaping (Result<(), Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.set(permissions, forKey: .permissions)
        }
    }
    
    // MARK: Matrix
    
    func getMatrixRelayServer(completion: @escaping (Result<String?, Error>) -> ()) {
        let relayServer = userDefaults.string(forKey: .matrixRelayServer)
        completion(.success(relayServer))
    }
    
    func setMatrixRelayServer(_ relayServer: String?, completion: @escaping (Result<(), Error>) -> ()) {
        if let relayServer = relayServer {
            userDefaults.set(relayServer, forKey: .matrixRelayServer)
        } else {
            userDefaults.removeObject(forKey: .matrixRelayServer)
        }
        
        completion(.success(()))
    }
    
    func getMatrixChannels(completion: @escaping (Result<[String : String], Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.get([String: String].self, forKey: .matrixChannels) ?? [:]
        }
    }
    
    func setMatrixChannels(_ channels: [String : String], completion: @escaping (Result<(), Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.set(channels, forKey: .matrixChannels)
        }
    }
    
    func getMatrixSyncToken(completion: @escaping (Result<String?, Error>) -> ()) {
        let token = userDefaults.string(forKey: .matrixSyncToken)
        completion(.success(token))
    }
    
    func setMatrixSyncToken(_ token: String, completion: @escaping (Result<(), Error>) -> ()) {
        userDefaults.set(token, forKey: .matrixSyncToken)
        completion(.success(()))
    }
    
    func getMatrixRooms(completion: @escaping (Result<[Matrix.Room], Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.get([Matrix.Room].self, forKey: .matrixRooms) ?? []
        }
    }
    
    func set(_ rooms: [Matrix.Room], completion: @escaping (Result<(), Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.set(rooms, forKey: .matrixRooms)
        }
    }
    
    // MARK: SDK
    
    func getSDKVersion(completion: @escaping (Result<String?, Error>) -> ()) {
        let version = userDefaults.string(forKey: .sdkVersion)
        completion(.success(version))
    }
    
    func setSDKVersion(_ version: String, completion: @escaping (Result<(), Error>) -> ()) {
        userDefaults.set(version, forKey: .sdkVersion)
        completion(.success(()))
    }
    
    func getMigrations(completion: @escaping (Result<Set<String>, Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.get(Set<String>.self, forKey: .migrations) ?? []
        }
    }
    
    func setMigrations(_ migrations: Set<String>, completion: @escaping (Result<(), Error>) -> ()) {
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
