//
//  Storage.swift
//  BeaconSDK
//
//  Created by Julia Samol on 10.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

protocol Storage {
    
    // MARK: Peers
    
    func getPeers(completion: @escaping (Result<[Beacon.Peer], Error>) -> ())
    func set(_ peers: [Beacon.Peer], completion: @escaping (Result<(), Error>) -> ())
    
    // MARK: AppMetadata
    
    func getAppMetadata(completion: @escaping (Result<[Beacon.AppMetadata], Error>) -> ())
    func set(_ appMetadata: [Beacon.AppMetadata], completion: @escaping (Result<(), Error>) -> ())
    
    // MARK: Permissions
    
    func getPermissions(completion: @escaping (Result<[Beacon.Permission], Error>) -> ())
    func set(_ permissions: [Beacon.Permission], completion: @escaping (Result<(), Error>) -> ())
    
    // MARK: Matrix
    
    func getMatrixRelayServer(completion: @escaping (Result<String?, Error>) -> ())
    func setMatrixRelayServer(_ relayServer: String?, completion: @escaping (Result<(), Error>) -> ())
    
    func getMatrixChannels(completion: @escaping (Result<[String: String], Swift.Error>) -> ())
    func setMatrixChannels(_ channels: [String: String], completion: @escaping (Result<(), Swift.Error>) -> ())
    
    func getMatrixSyncToken(completion: @escaping (Result<String?, Error>) -> ())
    func setMatrixSyncToken(_ token: String, completion: @escaping (Result<(), Error>) -> ())
    
    func getMatrixRooms(completion: @escaping (Result<[Matrix.Room], Error>) -> ())
    func set(_ rooms: [Matrix.Room], completion: @escaping (Result<(), Error>) -> ())
    
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
