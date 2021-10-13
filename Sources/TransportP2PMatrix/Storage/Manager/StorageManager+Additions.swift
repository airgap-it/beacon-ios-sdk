//
//  StorageManager+Additions.swift
//  
//
//  Created by Julia Samol on 27.09.21.
//

import Foundation
import BeaconCore

extension StorageManager {
    var p2pMatrixPlugin: P2PMatrixStoragePlugin? { plugins.first(where: { $0 is P2PMatrixStoragePlugin }) as? P2PMatrixStoragePlugin }
}

// MARK: ExtendedP2PMatrixStoragePlugin

extension StorageManager: ExtendedP2PMatrixStoragePlugin {
    
    private func extendedP2PMatrixPlugin() throws -> ExtendedP2PMatrixStoragePlugin {
        guard let plugin = p2pMatrixPlugin else {
            throw Error.missingPlugin("P2P Matrix")
        }
        
        return plugin.extend()
    }
    
    public func getMatrixRelayServer(completion: @escaping (Result<String?, Swift.Error>) -> ()) {
        runCatching(completion: completion) {
            try extendedP2PMatrixPlugin().getMatrixRelayServer(completion: completion)
        }
    }
    
    public func setMatrixRelayServer(_ relayServer: String?, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        runCatching(completion: completion) {
            try extendedP2PMatrixPlugin().setMatrixRelayServer(relayServer, completion: completion)
        }
    }
    
    public func removeMatrixRelayServer(completion: @escaping (Result<(), Swift.Error>) -> ()) {
        runCatching(completion: completion) {
            try extendedP2PMatrixPlugin().removeMatrixRelayServer(completion: completion)
        }
    }
    
    public func getMatrixChannels(completion: @escaping (Result<[String : String], Swift.Error>) -> ()) {
        runCatching(completion: completion) {
            try extendedP2PMatrixPlugin().getMatrixChannels(completion: completion)
        }
    }
    
    public func setMatrixChannels(_ channels: [String : String], completion: @escaping (Result<(), Swift.Error>) -> ()) {
        runCatching(completion: completion) {
            try extendedP2PMatrixPlugin().setMatrixChannels(channels, completion: completion)
        }
    }
    
    public func removeMatrixChannels(completion: @escaping (Result<(), Swift.Error>) -> ()) {
        runCatching(completion: completion) {
            try extendedP2PMatrixPlugin().removeMatrixChannels(completion: completion)
        }
    }
    
    public func getMatrixSyncToken(completion: @escaping (Result<String?, Swift.Error>) -> ()) {
        runCatching(completion: completion) {
            try extendedP2PMatrixPlugin().getMatrixSyncToken(completion: completion)
        }
    }
    
    public func setMatrixSyncToken(_ token: String?, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        runCatching(completion: completion) {
            try extendedP2PMatrixPlugin().setMatrixSyncToken(token, completion: completion)
        }
    }
    
    public func removeMatrixSyncToken(completion: @escaping (Result<(), Swift.Error>) -> ()) {
        runCatching(completion: completion) {
            try extendedP2PMatrixPlugin().removeMatrixSyncToken(completion: completion)
        }
    }
    
    public func getMatrixRooms(completion: @escaping (Result<[MatrixClient.Room], Swift.Error>) -> ()) {
        runCatching(completion: completion) {
            try extendedP2PMatrixPlugin().getMatrixRooms(completion: completion)
        }
    }
    
    public func set(_ rooms: [MatrixClient.Room], completion: @escaping (Result<(), Swift.Error>) -> ()) {
        runCatching(completion: completion) {
            try extendedP2PMatrixPlugin().set(rooms, completion: completion)
        }
    }
    
    public func removeMatrixRooms(completion: @escaping (Result<(), Swift.Error>) -> ()) {
        runCatching(completion: completion) {
            try extendedP2PMatrixPlugin().removeMatrixRooms(completion: completion)
        }
    }
}
