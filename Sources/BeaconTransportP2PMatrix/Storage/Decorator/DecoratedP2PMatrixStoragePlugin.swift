//
//  DecoratedP2PMatrixStoragePlugin.swift
//  
//
//  Created by Julia Samol on 27.09.21.
//

import Foundation

struct DecoratedP2PMatrixStoragePlugin: ExtendedP2PMatrixStoragePlugin {
    private let storagePlugin: P2PMatrixStoragePlugin
    
    init(storagePlugin: P2PMatrixStoragePlugin) {
        self.storagePlugin = storagePlugin
    }
    
    func getMatrixRelayServer(completion: @escaping (Result<String?, Error>) -> ()) {
        storagePlugin.getMatrixRelayServer(completion: completion)
    }

    func setMatrixRelayServer(_ relayServer: String?, completion: @escaping (Result<(), Error>) -> ()) {
        storagePlugin.setMatrixRelayServer(relayServer, completion: completion)
    }

    func removeMatrixRelayServer(completion: @escaping (Result<(), Error>) -> ()) {
        storagePlugin.setMatrixRelayServer(nil, completion: completion)
    }

    func getMatrixChannels(completion: @escaping (Result<[String : String], Error>) -> ()) {
        storagePlugin.getMatrixChannels(completion: completion)
    }

    func setMatrixChannels(_ channels: [String : String], completion: @escaping (Result<(), Error>) -> ()) {
        storagePlugin.setMatrixChannels(channels, completion: completion)
    }

    func removeMatrixChannels(completion: @escaping (Result<(), Error>) -> ()) {
        storagePlugin.setMatrixChannels([:], completion: completion)
    }

    func getMatrixSyncToken(completion: @escaping (Result<String?, Error>) -> ()) {
        storagePlugin.getMatrixSyncToken(completion: completion)
    }
    
    func setMatrixSyncToken(_ token: String?, completion: @escaping (Result<(), Error>) -> ()) {
        storagePlugin.setMatrixSyncToken(token, completion: completion)
    }
    
    func removeMatrixSyncToken(completion: @escaping (Result<(), Error>) -> ()) {
        storagePlugin.setMatrixSyncToken(nil, completion: completion)
    }

    func getMatrixRooms(completion: @escaping (Result<[MatrixClient.Room], Error>) -> ()) {
        storagePlugin.getMatrixRooms(completion: completion)
    }

    func set(_ rooms: [MatrixClient.Room], completion: @escaping (Result<(), Error>) -> ()) {
        storagePlugin.set(rooms, completion: completion)
    }

    func removeMatrixRooms(completion: @escaping (Result<(), Error>) -> ()) {
        storagePlugin.set([MatrixClient.Room](), completion: completion)
    }
}
