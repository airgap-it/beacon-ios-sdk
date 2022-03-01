//
//  MockDependencyRegistry.swift
//  
//
//  Created by Julia Samol on 11.10.21.
//

import Foundation
@testable import BeaconCore

public class MockDependencyRegistry: DependencyRegistry {
    private let coreDependencyRegistry: CoreDependencyRegistry
    
    public private(set) var afterInitializationCalls: Int = 0
    
    public init() {
        self.coreDependencyRegistry = CoreDependencyRegistry(
            blockchainFactories: [MockBlockchainFactory()],
            storage: MockStorage(),
            secureStorage: MockSecureStorage()
        )
    }
    
    public var extended: [String : DependencyRegistry] { coreDependencyRegistry.extended }
    
    public func addExtended<T>(_ extended: T) where T : DependencyRegistry {
        coreDependencyRegistry.addExtended(extended)
    }
    
    public func findExtended<T>() -> T? where T : DependencyRegistry {
        coreDependencyRegistry.findExtended()
    }
    
    public var storageManager: StorageManager { coreDependencyRegistry.storageManager }
    
    public func connectionController(configuredWith connections: [Beacon.Connection]) throws -> ConnectionControllerProtocol {
        MockConnectionController()
    }
    
    public var messageController: MessageControllerProtocol { MockMessageController(storageManager: self.storageManager) }
    
    public func transport(configuredWith connection: Beacon.Connection) throws -> Transport {
        MockTransport(kind: connection.kind)
    }
    
    public var blockchainRegistry: BlockchainRegistryProtocol { MockBlockchainRegistry() }
    public var crypto: Crypto { coreDependencyRegistry.crypto }
    public var serializer: Serializer { coreDependencyRegistry.serializer }
    
    public func http(urlSession: URLSession) -> HTTP {
        coreDependencyRegistry.http(urlSession: urlSession)
    }
    
    public var migration: Migration { coreDependencyRegistry.migration }
    public var identifierCreator: IdentifierCreatorProtocol { MockIdentifierCreator() }
    public var time: TimeProtocol { MockTime() }
    
    public func afterInitialization(completion: @escaping (Result<(), Error>) -> ()) {
        afterInitializationCalls += 1
        completion(.success(()))
    }
}
