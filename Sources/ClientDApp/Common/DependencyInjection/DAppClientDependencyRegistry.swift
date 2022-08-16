//
//  DAppClientDependencyRegistry.swift
//  
//
//  Created by Julia Samol on 11.08.22.
//

import Foundation
import BeaconCore

class DAppClientDependencyRegistry: ExtendedDependencyRegistry {
    private let dependencyRegistry: DependencyRegistry
    
    init(dependencyRegistry: DependencyRegistry) {
        self.dependencyRegistry = dependencyRegistry
    }
    
    // MARK: Client
    
    private var dAppClient: Beacon.DAppClient? = nil
    func dAppClient(storagePlugin: DAppClientStoragePlugin, connections: [Beacon.Connection]) throws -> Beacon.DAppClient {
        if storageManager.dAppClientPlugin == nil {
            storageManager.addPlugins([storagePlugin.extend()])
        }
        
        guard let dAppClient = dAppClient else {
            let beacon = try beacon()
            
            let dAppClient = Beacon.DAppClient(
                app: beacon.app,
                beaconID: beacon.beaconID,
                storageManager: storageManager,
                connectionController: try connectionController(configuredWith: connections),
                messageController: messageController,
                accountController: accountController,
                crypto: crypto,
                serializer: serializer,
                identifierCreator: identifierCreator
            )
            
            self.dAppClient = dAppClient
            return dAppClient
        }
        
        return dAppClient
    }
    
    // MARK: Controllers
    
    var accountController: AccountControllerProtocol { weakAccountController.value }
    private lazy var weakAccountController: LazyWeakReference<AccountController> = LazyWeakReference { [unowned self] in
        AccountController(store: .init(storageManager: self.storageManager), blockchainRegistry: self.blockchainRegistry)
    }
    
    // MARK: Derived
    
    var extended: [String: DependencyRegistry] { dependencyRegistry.extended }
    
    func addExtended<T>(_ registry: T) where T : DependencyRegistry {
        dependencyRegistry.addExtended(registry)
    }
    
    func findExtended<T>() -> T? where T : DependencyRegistry {
        dependencyRegistry.findExtended()
    }
    
    var storageManager: StorageManager { dependencyRegistry.storageManager }
    
    func connectionController(configuredWith connections: [Beacon.Connection]) throws -> ConnectionControllerProtocol {
        try dependencyRegistry.connectionController(configuredWith: connections)
    }
    
    var messageController: MessageControllerProtocol { dependencyRegistry.messageController }
    
    func transport(configuredWith connection: Beacon.Connection) throws -> Transport {
        try dependencyRegistry.transport(configuredWith: connection)
    }
    
    var blockchainRegistry: BlockchainRegistryProtocol { dependencyRegistry.blockchainRegistry }
    var crypto: Crypto { dependencyRegistry.crypto }
    var serializer: Serializer { dependencyRegistry.serializer }
    
    func http(urlSession: URLSession) -> HTTP {
        dependencyRegistry.http(urlSession: urlSession)
    }
    
    var migration: Migration { dependencyRegistry.migration }
    
    var identifierCreator: IdentifierCreatorProtocol { dependencyRegistry.identifierCreator }
    var time: TimeProtocol { dependencyRegistry.time }
    
    func afterInitialization(completion: @escaping (Result<(), Error>) -> ()) {
        dependencyRegistry.afterInitialization(completion: completion)
    }
}
