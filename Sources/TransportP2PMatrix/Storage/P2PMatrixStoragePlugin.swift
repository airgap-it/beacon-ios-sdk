//
//  P2PMatrixStoragePlugin.swift
//  
//
//  Created by Julia Samol on 27.09.21.
//

import Foundation
import BeaconCore

public protocol P2PMatrixStoragePlugin: StoragePlugin {
    func getMatrixRelayServer(completion: @escaping (Result<String?, Error>) -> ())
    func setMatrixRelayServer(_ relayServer: String?, completion: @escaping (Result<(), Error>) -> ())

    func getMatrixChannels(completion: @escaping (Result<[String: String], Swift.Error>) -> ())
    func setMatrixChannels(_ channels: [String: String], completion: @escaping (Result<(), Swift.Error>) -> ())

    func getMatrixSyncToken(completion: @escaping (Result<String?, Error>) -> ())
    func setMatrixSyncToken(_ token: String?, completion: @escaping (Result<(), Error>) -> ())

    func getMatrixRooms(completion: @escaping (Result<[MatrixClient.Room], Error>) -> ())
    func set(_ rooms: [MatrixClient.Room], completion: @escaping (Result<(), Error>) -> ())
}

// MARK: Extensions

extension P2PMatrixStoragePlugin {
    public func extend() -> ExtendedP2PMatrixStoragePlugin {
        if let extended = self as? ExtendedP2PMatrixStoragePlugin {
            return extended
        } else {
            return DecoratedP2PMatrixStoragePlugin(storagePlugin: self)
        }
    }
}
