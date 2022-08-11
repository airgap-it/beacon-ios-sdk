//
//  ExtendedP2PMatrixStoragePlugin.swift
//  
//
//  Created by Julia Samol on 27.09.21.
//

import Foundation

public protocol ExtendedP2PMatrixStoragePlugin: P2PMatrixStoragePlugin {
    func removeMatrixRelayServer(completion: @escaping (Result<(), Error>) -> ())
    func removeMatrixChannels(completion: @escaping (Result<(), Error>) -> ())
    func removeMatrixSyncToken(completion: @escaping (Result<(), Error>) -> ())
    func removeMatrixRooms(completion: @escaping (Result<(), Error>) -> ())
}

// MARK: Extensions

extension ExtendedP2PMatrixStoragePlugin {
    public func extend() -> ExtendedP2PMatrixStoragePlugin {
        self
    }
}
