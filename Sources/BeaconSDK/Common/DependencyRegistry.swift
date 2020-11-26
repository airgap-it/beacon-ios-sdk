//
//  DependencyRegistry.swift
//  BeaconSDK
//
//  Created by Julia Samol on 10.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

class DependencyRegistry {
    let storage: ExtendedStorage
    
    init(storage: Storage) {
        self.storage = storage.extend()
    }
    
    // MARK: Controller
    
    func connectionController(configuredWith connections: [Beacon.Connection]) throws -> ConnectionControllerProtocol {
        let transports = try connections.map { try transport(configuredWith: $0) }
        return ConnectionController(transports: transports, serializer: serializer)
    }
    
    var messageController: MessageControllerProtocol { weakMessageController.value }
    private lazy var weakMessageController: LazyWeakReference<MessageController> = LazyWeakReference { [unowned self] in
        MessageController(coinRegistry: self.coinRegistry, storage: self.storage, accountUtils: self.accountUtils)
    }
    
    // MARK: Transport
    
    private var transports: [Beacon.Connection: LazyWeakReference<Transport>] = [:]
    func transport(configuredWith connection: Beacon.Connection) throws -> Transport {
        try transports.getOrSet(connection) {
            switch connection {
            case let .p2p(configuration):
                guard let beacon = Beacon.shared else {
                    throw Beacon.Error.uninitialized
                }
                
                let replicationCount = Beacon.Configuration.p2pReplicationCount
                
                let p2pServerUtils = Transport.P2P.ServerUtils(crypto: crypto, nodes: configuration.nodes)
                let matrixClients: [Matrix] = try (0..<replicationCount).map {
                    let relayServer = try p2pServerUtils.relayServer(for: beacon.keyPair.publicKey, nonce: HexString(from: $0))
                    return matrix(baseURL: relayServer.appendingPathComponent(Beacon.Configuration.matrixAPI))
                }
                
                let client = Transport.P2P.CommunicationClient(
                    appName: beacon.appName,
                    communicationUtils: Transport.P2P.CommunicationUtils(crypto: crypto),
                    serverUtils: p2pServerUtils,
                    matrixClients: matrixClients,
                    replicationCount: replicationCount,
                    crypto: crypto,
                    keyPair: beacon.keyPair
                )
                
                return LazyWeakReference { [unowned self] in Transport.P2P(client: client, storage: self.storage) }
            }
        }.value
    }
    
    // MARK: Coin
    
    var coinRegistry: CoinRegistry { weakCoinRegistry.value }
    private lazy var weakCoinRegistry: LazyWeakReference<CoinRegistry> = LazyWeakReference { [unowned self] in
        CoinRegistry(crypto: self.crypto)
    }
    
    // MARK: Crypto
    
    var crypto: Crypto { weakCrypto.value }
    private lazy var weakCrypto: LazyWeakReference<Crypto> = LazyWeakReference { [unowned self] in
        let cryptoProvider: CryptoProvider = {
            switch Beacon.Configuration.cryptoProvider {
            case .sodium:
                return SodiumCryptoProvider()
            }
        }()
            
        return Crypto(provider: cryptoProvider)
    }
    
    
    // MARK: Serializer
    
    var serializer: Serializer {
        switch Beacon.Configuration.serializer {
        case .base58check:
            return weakBase58Serializer.value
        }
    }
    private lazy var weakBase58Serializer: LazyWeakReference<Base58CheckSerializer> = LazyWeakReference {
        Base58CheckSerializer()
    }
    
    // MARK: Matrix
    
    private func matrix(baseURL: URL) -> Matrix {
        Matrix(
            store: Matrix.Store(storage: storage),
            userService: matrixUserService(baseURL: baseURL),
            eventService: matrixEventService(baseURL: baseURL),
            roomService: matrixRoomService(baseURL: baseURL)
        )
    }
    
    private var matrixUserServices: [URL: LazyWeakReference<Matrix.UserService>] = [:]
    private func matrixUserService(baseURL: URL) -> Matrix.UserService {
        matrixUserServices.getOrSet(baseURL) {
            LazyWeakReference { Matrix.UserService(http: HTTP(baseURL: baseURL)) }
        }.value
    }
    
    private var matrixEventServices: [URL: LazyWeakReference<Matrix.EventService>] = [:]
    private func matrixEventService(baseURL: URL) -> Matrix.EventService {
        matrixEventServices.getOrSet(baseURL) {
            LazyWeakReference { Matrix.EventService(http: HTTP(baseURL: baseURL)) }
        }.value
    }
    
    private var matrixRoomServices: [URL: LazyWeakReference<Matrix.RoomService>] = [:]
    private func matrixRoomService(baseURL: URL) -> Matrix.RoomService {
        matrixRoomServices.getOrSet(baseURL) {
            LazyWeakReference { Matrix.RoomService(http: HTTP(baseURL: baseURL)) }
        }.value
    }
    
    // MARK: Other
    
    private var accountUtils: AccountUtils { weakAccountUtils.value }
    private lazy var weakAccountUtils: LazyWeakReference<AccountUtils> = LazyWeakReference { [unowned self] in
        AccountUtils(crypto: self.crypto)
    }
}
