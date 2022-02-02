//
//  CoreDependencyRegistry.swift
//  
//
//  Created by Julia Samol on 27.09.21.
//

import Foundation

class CoreDependencyRegistry: DependencyRegistry {
    
    init(blockchainFactories: [BlockchainFactory], storage: Storage, secureStorage: SecureStorage) {
        self.blockchainFactories = blockchainFactories
        self.storage = storage
        self.secureStorage = secureStorage
    }
    
    // MARK: Extended
    
    public private(set) var extended: [String: DependencyRegistry] = [:]
    
    public func addExtended<T: DependencyRegistry>(_ registry: T) {
        extended["\(T.self)"] = registry
    }
    
    public func findExtended<T: DependencyRegistry>() -> T? {
        extended["\(T.self)"] as? T
    }
    
    // MARK: Storage
    
    private let storage: Storage
    private let secureStorage: SecureStorage
    
    public var storageManager: StorageManager { weakStorageManager.value }
    private lazy var weakStorageManager: LazyWeakReference<StorageManager> = LazyWeakReference { [unowned self] in
        StorageManager(storage: self.storage, secureStorage: self.secureStorage, identifierCreator: self.identifierCreator)
    }
    
    // MARK: Controller
    
    public func connectionController(configuredWith connections: [Beacon.Connection]) throws -> ConnectionControllerProtocol {
        let transports = try connections.map { try transport(configuredWith: $0) }
        return ConnectionController(transports: transports, serializer: serializer)
    }
    
    public var messageController: MessageControllerProtocol { weakMessageController.value }
    private lazy var weakMessageController: LazyWeakReference<MessageController> = LazyWeakReference { [unowned self] in
        MessageController(
            blockchainRegistry: self.blockchainRegistry,
            storageManager: self.storageManager,
            identifierCreator: self.identifierCreator,
            time: self.time
        )
    }
    
    // MARK: Transport
    
    public func transport(configuredWith connection: Beacon.Connection) throws -> Transport {
        switch connection {
        case let .p2p(configuration):
            return Transport.P2P(client: try configuration.client.create(with: self), storageManager: self.storageManager)
        }
    }
    
    // MARK: Blockchain
    
    private let blockchainFactories: [BlockchainFactory]
    public var blockchainRegistry: BlockchainRegistryProtocol { weakBlockchainRegistry.value }
    private lazy var weakBlockchainRegistry: LazyWeakReference<BlockchainRegistry> = LazyWeakReference { [unowned self] in
        let factories = self.blockchainFactories
            .grouped(by: { type(of: $0).identifier })
            .mapValues { factory in { factory.createShadow(with: self) } }
        
        return BlockchainRegistry(factories: factories)
    }
    
    // MARK: Crypto
    
    public var crypto: Crypto { weakCrypto.value }
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
    
    public var serializer: Serializer {
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
    public func http(urlSession: URLSession) -> HTTP {
        https.get(urlSession.hashValue) {
            LazyWeakReference { HTTP(session: urlSession) }
        }.value
    }
    
    // MARK: Migration
    
    public var migration: Migration { weakMigration.value }
    private lazy var weakMigration: LazyWeakReference<Migration> = LazyWeakReference { [unowned self] in
        Migration(
            storageManager: self.storageManager,
            migrations: []
        )
    }
    
    // MARK: Other
    
    public var identifierCreator: IdentifierCreatorProtocol { weakIdentifierCreator.value }
    private lazy var weakIdentifierCreator: LazyWeakReference<IdentifierCreator> = LazyWeakReference { [unowned self] in
        IdentifierCreator(crypto: self.crypto)
    }
    
    public var time: TimeProtocol { weakTime.value }
    private lazy var weakTime: LazyWeakReference<Time> = LazyWeakReference { Time() }
}
