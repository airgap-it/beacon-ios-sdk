//
//  UserDefaultsDAppClientStorage.swift
//  
//
//  Created by Julia Samol on 11.08.22.
//

import Foundation
import BeaconCore

struct UserDefaultsDAppClientStorage: DAppClientStorage {
    private let userDefaults: UserDefaults
    private let storage: Storage
    
    init(storage: Storage, userDefaults: UserDefaults = .standard) {
        self.storage = storage
        self.userDefaults = userDefaults
    }
    
    // MARK: Account
    
    func getActiveAccount(completion: @escaping (Result<PairedAccount?, Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.get(PairedAccount.self, forKey: .activeAccount)
        }
    }
    
    func setActiveAccount(_ account: PairedAccount?, completion: @escaping (Result<(), Error>) -> ()) {
        completeCatching(completion: completion) {
            if let account = account {
                try userDefaults.set(account, forKey: .activeAccount)
            } else {
                userDefaults.removeObject(forKey: .activeAccount)
            }
        }
    }
    
    // MARK: Active Peer
    
    func getActivePeer(completion: @escaping (Result<String?, Error>) -> ()) {
        let peerID = userDefaults.string(forKey: .activePeerID)
        completion(.success(peerID))
    }
    
    func setActivePeer(_ peerID: String?, completion: @escaping (Result<(), Error>) -> ()) {
        if let peerID = peerID {
            userDefaults.set(peerID, forKey: .activePeerID)
        } else {
            userDefaults.removeObject(forKey: .activePeerID)
        }
        completion(.success(()))
    }
    
    // MARK: Peers
    
    func getPeers(completion: @escaping (Result<[Beacon.Peer], Error>) -> ()) {
        storage.getPeers(completion: completion)
    }
    
    func set(_ peers: [Beacon.Peer], completion: @escaping (Result<(), Error>) -> ()) {
        storage.set(peers, completion: completion)
    }
    
    // MARK: AppMetadata
    
    func getAppMetadata<T>(completion: @escaping (Result<[T], Error>) -> ()) where T : AppMetadataProtocol {
        storage.getAppMetadata(completion: completion)
    }
    
    func set<T>(_ appMetadata: [T], completion: @escaping (Result<(), Error>) -> ()) where T : AppMetadataProtocol {
        storage.set(appMetadata, completion: completion)
    }
    
    func getLegacyAppMetadata<T>(completion: @escaping (Result<[T], Error>) -> ()) where T : LegacyAppMetadataProtocol {
        storage.getLegacyAppMetadata(completion: completion)
    }
    
    func setLegacy<T>(_ appMetadata: [T], completion: @escaping (Result<(), Error>) -> ()) where T : LegacyAppMetadataProtocol {
        storage.setLegacy(appMetadata, completion: completion)
    }
    
    // MARK: Permissions
    
    func getPermissions<T>(completion: @escaping (Result<[T], Error>) -> ()) where T : PermissionProtocol {
        storage.getPermissions(completion: completion)
    }
    
    func set<T>(_ permissions: [T], completion: @escaping (Result<(), Error>) -> ()) where T : PermissionProtocol {
        storage.set(permissions, completion: completion)
    }
    
    func getLegacyPermissions<T>(completion: @escaping (Result<[T], Error>) -> ()) where T : LegacyPermissionProtocol {
        storage.getLegacyPermissions(completion: completion)
    }
    
    func setLegacy<T>(_ permissions: [T], completion: @escaping (Result<(), Error>) -> ()) where T : LegacyPermissionProtocol {
        storage.setLegacy(permissions, completion: completion)
    }
    
    // MARK: SDK
    
    func getSDKVersion(completion: @escaping (Result<String?, Error>) -> ()) {
        storage.getSDKVersion(completion: completion)
    }
    
    func setSDKVersion(_ version: String, completion: @escaping (Result<(), Error>) -> ()) {
        storage.setSDKVersion(version, completion: completion)
    }
    
    func getMigrations(completion: @escaping (Result<Set<String>, Error>) -> ()) {
        storage.getMigrations(completion: completion)
    }
    
    func setMigrations(_ migrations: Set<String>, completion: @escaping (Result<(), Error>) -> ()) {
        storage.setMigrations(migrations, completion: completion)
    }
    
    // MARK: Types
    
    enum Key: String {
        case activeAccount = "dappActiveAccount"
        case activePeerID = "dappActivePeerID"
    }
}

// MARK: Extensions

private extension UserDefaults {
    func set(_ value: String, forKey key: UserDefaultsDAppClientStorage.Key) {
        set(value, forKey: key.rawValue)
    }
    
    func set<T: Codable>(
        _ value: T,
        forKey key: UserDefaultsDAppClientStorage.Key,
        blockchainIdentifier: String? = nil,
        version: String? = nil
    ) throws {
        let propertyListEncoder = PropertyListEncoder()
        set(try propertyListEncoder.encode(value), forKey: self.key(from: key, blockchainIdentifier: blockchainIdentifier, andVersion: version))
    }
    
    func string(forKey key: UserDefaultsDAppClientStorage.Key) -> String? {
        string(forKey: key.rawValue)
    }
    
    func get<T: Codable>(
        _ type: T.Type,
        forKey key: UserDefaultsDAppClientStorage.Key,
        blockchainIdentifier: String? = nil,
        version: String? = nil
    ) throws -> T? {
        let propertyListDecoder = PropertyListDecoder()
        if let data = data(forKey: self.key(from: key, blockchainIdentifier: blockchainIdentifier, andVersion: version)) {
            return try propertyListDecoder.decode(type, from: data)
        } else {
            return nil
        }
    }
    
    func removeObject(forKey key: UserDefaultsDAppClientStorage.Key, blockchainIdentifier: String? = nil, version: String? = nil) {
        removeObject(forKey: self.key(from: key, blockchainIdentifier: blockchainIdentifier, andVersion: version))
    }
    
    private func key(
        from key: UserDefaultsDAppClientStorage.Key,
        blockchainIdentifier: String?,
        andVersion version: String?
    ) -> String {
        let specifiers = [blockchainIdentifier, version].compactMap { $0 }
        
        if !specifiers.isEmpty {
            return "\(key.rawValue)_\(specifiers.joined(separator: "_"))"
        } else {
            return key.rawValue
        }
    }
}
