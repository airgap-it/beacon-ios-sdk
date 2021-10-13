//
//  UserDefaultsP2PMatrixStoragePlugin.swift
//  
//
//  Created by Julia Samol on 27.09.21.
//

import Foundation
import BeaconCore

public struct UserDefaultsP2PMatrixStoragePlugin: P2PMatrixStoragePlugin {
    
    private let userDefaults: UserDefaults
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: Matrix
    
    public func getMatrixRelayServer(completion: @escaping (Result<String?, Error>) -> ()) {
        let relayServer = userDefaults.string(forKey: .matrixRelayServer)
        completion(.success(relayServer))
    }
    
    public func setMatrixRelayServer(_ relayServer: String?, completion: @escaping (Result<(), Error>) -> ()) {
        if let relayServer = relayServer {
            userDefaults.set(relayServer, forKey: .matrixRelayServer)
        } else {
            userDefaults.removeObject(forKey: .matrixRelayServer)
        }
        
        completion(.success(()))
    }
    
    public func getMatrixChannels(completion: @escaping (Result<[String : String], Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.get([String: String].self, forKey: .matrixChannels) ?? [:]
        }
    }
    
    public func setMatrixChannels(_ channels: [String : String], completion: @escaping (Result<(), Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.set(channels, forKey: .matrixChannels)
        }
    }
    
    public func getMatrixSyncToken(completion: @escaping (Result<String?, Error>) -> ()) {
        let token = userDefaults.string(forKey: .matrixSyncToken)
        completion(.success(token))
    }
    
    public func setMatrixSyncToken(_ token: String?, completion: @escaping (Result<(), Error>) -> ()) {
        if let token = token {
            userDefaults.set(token, forKey: .matrixSyncToken)
        } else {
            userDefaults.removeObject(forKey: .matrixSyncToken)
        }
        
        completion(.success(()))
    }
    
    public func getMatrixRooms(completion: @escaping (Result<[MatrixClient.Room], Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.get([MatrixClient.Room].self, forKey: .matrixRooms) ?? []
        }
    }

    public func set(_ rooms: [MatrixClient.Room], completion: @escaping (Result<(), Error>) -> ()) {
        completeCatching(completion: completion) {
            try userDefaults.set(rooms, forKey: .matrixRooms)
        }
    }
    
    // MARK: Types
    
    enum Key: String {
        case matrixRelayServer
        case matrixChannels
        case matrixSyncToken
        case matrixRooms
    }
}

// MARK: Extensions

private extension UserDefaults {
    func set(_ value: String, forKey key: UserDefaultsP2PMatrixStoragePlugin.Key) {
        set(value, forKey: key.rawValue)
    }
    
    func set<T: Codable>(_ value: T, forKey key: UserDefaultsP2PMatrixStoragePlugin.Key) throws {
        let propertyListEncoder = PropertyListEncoder()
        set(try propertyListEncoder.encode(value), forKey: key.rawValue)
    }
    
    func string(forKey key: UserDefaultsP2PMatrixStoragePlugin.Key) -> String? {
        string(forKey: key.rawValue)
    }
    
    func get<T: Codable>(_ type: T.Type, forKey key: UserDefaultsP2PMatrixStoragePlugin.Key) throws -> T? {
        let propertyListDecoder = PropertyListDecoder()
        if let data = data(forKey: key.rawValue) {
            return try propertyListDecoder.decode(type, from: data)
        } else {
            return nil
        }
    }
    
    func removeObject(forKey key: UserDefaultsP2PMatrixStoragePlugin.Key) {
        removeObject(forKey: key.rawValue)
    }
}
