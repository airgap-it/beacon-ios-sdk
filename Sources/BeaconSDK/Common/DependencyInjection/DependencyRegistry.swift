//
//  DependencyRegistry.swift
//  BeaconSDK
//
//  Created by Julia Samol on 10.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

class DependencyRegistry {
    
    init(storage: Storage, secureStorage: SecureStorage) {
        self.storage = storage
        self.secureStorage = secureStorage
    }
    
    // MARK: Storage
    private let storage: Storage
    private let secureStorage: SecureStorage
    
    var storageManager: StorageManager { weakStorageManager.value }
    private lazy var weakStorageManager: LazyWeakReference<StorageManager> = LazyWeakReference { [unowned self] in
        StorageManager(storage: self.storage, secureStorage: self.secureStorage, accountUtils: self.accountUtils)
    }
    
    // MARK: Controller
    
    func connectionController(configuredWith connections: [Beacon.Connection]) throws -> ConnectionControllerProtocol {
        let transports = try connections.map { try transport(configuredWith: $0) }
        return ConnectionController(transports: transports, serializer: serializer)
    }
    
    var messageController: MessageControllerProtocol { weakMessageController.value }
    private lazy var weakMessageController: LazyWeakReference<MessageController> = LazyWeakReference { [unowned self] in
        MessageController(
            coinRegistry: self.coinRegistry,
            storageManager: self.storageManager,
            accountUtils: self.accountUtils,
            timeUtils: self.timeUtils
        )
    }
    
    // MARK: Transport
    
    private var transports: [Beacon.Connection: LazyWeakReference<Transport>] = [:]
    func transport(configuredWith connection: Beacon.Connection) throws -> Transport {
        try transports.get(connection) {
            switch connection {
            case let .p2p(configuration):
                guard let beacon = Beacon.shared else {
                    throw Beacon.Error.uninitialized
                }
                
                let matrix = matrix(urlSession: configuration.urlSession)
                
                let communicationUtils = Transport.P2P.CommunicationUtils(app: beacon.app, crypto: crypto)
                let store = Transport.P2P.Store(
                    app: beacon.app,
                    communicationUtils: communicationUtils,
                    matrixClient: matrix,
                    matrixNodes: configuration.nodes,
                    storageManager: storageManager,
                    migration: migration
                )
                let cryptoUtils = Transport.P2P.CryptoUtils(app: beacon.app, crypto: crypto, timeUtils: timeUtils)
                
                let client = Transport.P2P.Client(
                    matrixClient: matrix,
                    store: store,
                    cryptoUtils: cryptoUtils,
                    communicationUtils: communicationUtils
                )
                
                return LazyWeakReference { [unowned self] in Transport.P2P(client: client, storageManager: self.storageManager) }
            }
        }.value
    }
    
    // MARK: Coin
    
    var coinRegistry: CoinRegistryProtocol { weakCoinRegistry.value }
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
    
    // MARK: Network
    
    private var https: [Int: LazyWeakReference<HTTP>] = [:]
    private func http(urlSession: URLSession) -> HTTP {
        https.get(urlSession.hashValue) {
            LazyWeakReference { HTTP(session: urlSession) }
        }.value
    }
    
    // MARK: Matrix
    
    private func matrix(urlSession: URLSession) -> Matrix {
        let http = self.http(urlSession: urlSession)
        
        return Matrix(
            store: Matrix.Store(storageManager: self.storageManager),
            nodeService: Matrix.NodeService(http: http),
            userService: Matrix.UserService(http: http),
            eventService: Matrix.EventService(http: http),
            roomService: Matrix.RoomService(http: http),
            timeUtils: self.timeUtils
        )
    }
    
    // MARK: Migration
    
    private var migration: Migration { weakMigration.value }
    private lazy var weakMigration: LazyWeakReference<Migration> = LazyWeakReference { [unowned self] in
        Migration(
            storageManager: self.storageManager,
            migrations: [
                Migration.From1_0_4(storageManager: self.storageManager)
            ]
        )
    }
    
    // MARK: Other
    
    private var accountUtils: AccountUtilsProtocol { weakAccountUtils.value }
    private lazy var weakAccountUtils: LazyWeakReference<AccountUtils> = LazyWeakReference { [unowned self] in
        AccountUtils(crypto: self.crypto)
    }
    
    private var timeUtils: TimeUtilsProtocol { weakTimeUtils.value }
    private lazy var weakTimeUtils: LazyWeakReference<TimeUtils> = LazyWeakReference { TimeUtils() }
}
