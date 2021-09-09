//
//  MockStorage.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

@testable import BeaconSDK

class MockStorage: Storage {
    var peers: [Beacon.Peer] = []
    var appMetadata: [Beacon.AppMetadata] = []
    var permissions: [Beacon.Permission] = []
    var matrixRelayServer: String?
    var matrixChannels: [String: String] = [:]
    var matrixSyncToken: String?
    var matrixRooms: [Matrix.Room] = []
    var sdkVersion: String?
    var migrations: Set<String> = []
    
    // MARK: Peers
    
    func getPeers(completion: @escaping (Result<[Beacon.Peer], Error>) -> ()) {
        completion(.success(peers))
    }
    
    func set(_ peers: [Beacon.Peer], completion: @escaping (Result<(), Error>) -> ()) {
        self.peers = peers
        completion(.success(()))
    }
    
    // MARK: AppMetadata
    
    func getAppMetadata(completion: @escaping (Result<[Beacon.AppMetadata], Error>) -> ()) {
        completion(.success(appMetadata))
    }
    
    func set(_ appMetadata: [Beacon.AppMetadata], completion: @escaping (Result<(), Error>) -> ()) {
        self.appMetadata = appMetadata
        completion(.success(()))
    }
    
    // MARK: Permissions
    
    func getPermissions(completion: @escaping (Result<[Beacon.Permission], Error>) -> ()) {
        completion(.success(permissions))
    }
    
    func set(_ permissions: [Beacon.Permission], completion: @escaping (Result<(), Error>) -> ()) {
        self.permissions = permissions
        completion(.success(()))
    }
    
    // MARK: Matrix
    
    func getMatrixRelayServer(completion: @escaping (Result<String?, Error>) -> ()) {
        completion(.success(matrixRelayServer))
    }
    
    func setMatrixRelayServer(_ relayServer: String?, completion: @escaping (Result<(), Error>) -> ()) {
        self.matrixRelayServer = relayServer
        completion(.success(()))
    }
    
    func getMatrixChannels(completion: @escaping (Result<[String : String], Error>) -> ()) {
        completion(.success(matrixChannels))
    }
    
    func setMatrixChannels(_ channels: [String : String], completion: @escaping (Result<(), Error>) -> ()) {
        self.matrixChannels = channels
        completion(.success(()))
    }
    
    func getMatrixSyncToken(completion: @escaping (Result<String?, Error>) -> ()) {
        completion(.success(matrixSyncToken))
    }
    
    func setMatrixSyncToken(_ token: String, completion: @escaping (Result<(), Error>) -> ()) {
        self.matrixSyncToken = token
        completion(.success(()))
    }
    
    func getMatrixRooms(completion: @escaping (Result<[Matrix.Room], Error>) -> ()) {
        completion(.success(matrixRooms))
    }
    
    func set(_ rooms: [Matrix.Room], completion: @escaping (Result<(), Error>) -> ()) {
        self.matrixRooms = rooms
        completion(.success(()))
    }
    
    // MARK: SDK
    
    func getSDKVersion(completion: @escaping (Result<String?, Error>) -> ()) {
        completion(.success(sdkVersion))
    }
    
    func setSDKVersion(_ version: String, completion: @escaping (Result<(), Error>) -> ()) {
        sdkVersion = version
        completion(.success(()))
    }
    
    func getMigrations(completion: @escaping (Result<Set<String>, Error>) -> ()) {
        completion(.success(migrations))
    }
    
    func setMigrations(_ migrations: Set<String>, completion: @escaping (Result<(), Error>) -> ()) {
        self.migrations = migrations
        completion(.success(()))
    }
}
