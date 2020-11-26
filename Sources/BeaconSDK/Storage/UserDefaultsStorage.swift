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
    
    func getPeers(completion: @escaping (Result<[Beacon.PeerInfo], Error>) -> ()) {
        do {
            completion(.success(try userDefaults.get([Beacon.PeerInfo].self, forKey: .peers) ?? []))
        } catch {
            completion(.failure(error))
        }
    }
    
    func set(_ peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Error>) -> ()) {
        do {
            try userDefaults.set(peers, forKey: .peers)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: AppMetadata
    
    func getAppMetadata(completion: @escaping (Result<[Beacon.AppMetadata], Error>) -> ()) {
        do {
            completion(.success(try userDefaults.get([Beacon.AppMetadata].self, forKey: .appMetadata) ?? []))
        } catch {
            completion(.failure(error))
        }
    }
    
    func set(_ appMetadata: [Beacon.AppMetadata], completion: @escaping (Result<(), Error>) -> ()) {
        do {
            try userDefaults.set(appMetadata, forKey: .appMetadata)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: Permissions
    
    func getPermissions(completion: @escaping (Result<[Beacon.PermissionInfo], Error>) -> ()) {
        do {
            completion(.success(try userDefaults.get([Beacon.PermissionInfo].self, forKey: .permissions) ?? []))
        } catch {
            completion(.failure(error))
        }
    }
    
    func set(_ permissions: [Beacon.PermissionInfo], completion: @escaping (Result<(), Error>) -> ()) {
        do {
            try userDefaults.set(permissions, forKey: .permissions)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: Matrix
    
    func getMatrixSyncToken(completion: @escaping (Result<String?, Error>) -> ()) {
        let token = userDefaults.string(forKey: .matrixSyncToken)
        completion(.success(token))
    }
    
    func setMatrixSyncToken(_ token: String, completion: @escaping (Result<(), Error>) -> ()) {
        userDefaults.set(token, forKey: .matrixSyncToken)
        completion(.success(()))
    }
    
    func getMatrixRooms(completion: @escaping (Result<[Matrix.Room], Error>) -> ()) {
        do {
            completion(.success(try userDefaults.get([Matrix.Room].self, forKey: .matrixRooms) ?? []))
        } catch {
            completion(.failure(error))
        }
    }
    
    func set(_ rooms: [Matrix.Room], completion: @escaping (Result<(), Error>) -> ()) {
        do {
            try userDefaults.set(rooms, forKey: .matrixRooms)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: SDK
    
    func getSDKSecretSeed(completion: @escaping (Result<String?, Error>) -> ()) {
        let seed = userDefaults.string(forKey: .sdkSecretSeed)
        completion(.success(seed))
    }
    
    func setSDKSecretSeed(_ seed: String, completion: @escaping (Result<(), Error>) -> ()) {
        userDefaults.set(seed, forKey: .sdkSecretSeed)
        completion(.success(()))
    }
    
    func getSDKVersion(completion: @escaping (Result<String?, Error>) -> ()) {
        let version = userDefaults.string(forKey: .sdkVersion)
        completion(.success(version))
    }
    
    func setSDKVersion(_ version: String, completion: @escaping (Result<(), Error>) -> ()) {
        userDefaults.set(version, forKey: .sdkVersion)
        completion(.success(()))
    }
    
    // MARK: Types
    
    enum Key: String {
        case peers
        case appMetadata
        case permissions
        case matrixSyncToken
        case matrixRooms
        case sdkSecretSeed
        case sdkVersion
    }
}

// MARK: Extensions

extension UserDefaults {
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
}
