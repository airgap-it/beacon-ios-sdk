//
//  Beacon.swift
//
//
//  Created by Julia Samol on 10.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public class Beacon {

    public private(set) static var shared: Beacon? = nil
    
    public let dependencyRegistry: DependencyRegistry
    public let app: Application
    
    public var beaconID: String {
        HexString(from: app.keyPair.publicKey).asString()
    }
    
    private init(dependencyRegistry: DependencyRegistry, app: Application) {
        self.dependencyRegistry = dependencyRegistry
        self.app = app
    }
    
    // MARK: Initialization
    
    public static func initialize(
        appName: String,
        appIcon: String?,
        appURL: String?,
        blockchainFactories: [BlockchainFactory],
        storage: Storage,
        secureStorage: SecureStorage,
        completion: @escaping (Result<(Beacon), Swift.Error>) -> ()
    ) {
        if let beacon = shared {
            completion(.success(beacon))
            return
        }
        
        let dependencyRegistry = CoreDependencyRegistry(blockchainFactories: blockchainFactories, storage: storage, secureStorage: secureStorage)
        Beacon.initialize(appName: appName, appIcon: appIcon, appURL: appURL, dependencyRegistry: dependencyRegistry, completion: completion)
    }
    
    static func initialize(
        appName: String,
        appIcon: String?,
        appURL: String?,
        dependencyRegistry: DependencyRegistry,
        completion: @escaping (Result<(Beacon), Swift.Error>) -> ()
    ) {
        if let beacon = shared {
            completion(.success(beacon))
            return
        }
        
        let crypto = dependencyRegistry.crypto
        let storageManager = dependencyRegistry.storageManager
        
        Compat.initialize(with: dependencyRegistry)
        
        setSDKVersion(savedWith: storageManager) { result in
            guard result.isSuccess(else: completion) else { return }
            
            self.loadOrGenerateKeyPair(using: crypto, savedWith: storageManager) { result in
                guard let keyPair = result.get(ifFailure: completion) else { return }
                let beacon = Beacon(
                    dependencyRegistry: dependencyRegistry,
                    app: Application(keyPair: keyPair, name: appName, icon: appIcon, url: appURL)
                )
                shared = beacon
                
                completion(.success(beacon))
            }
        }
    }
    
    private static func setSDKVersion(savedWith storage: StorageManager, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.setSDKVersion(Beacon.Configuration.sdkVersion, completion: completion)
    }
    
    private static func loadOrGenerateKeyPair(
        using crypto: Crypto,
        savedWith storageManager: StorageManager,
        completion: @escaping (Result<KeyPair, Swift.Error>) -> ()
    ) {
        storageManager.getSDKSecretSeed { result in
            guard let storageSeed = result.get(ifFailure: completion) else { return }
            
            if let seed = storageSeed {
                completion(runCatching { try crypto.keyPairFrom(seed: seed) })
            } else {
                self.generateKeyPair(using: crypto, savedWith: storageManager, completion: completion)
            }
        }
    }
    
    private static func generateKeyPair(
        using crypto: Crypto,
        savedWith storageManager: StorageManager,
        completion: @escaping (Result<KeyPair, Swift.Error>) -> ()
    ) {
        do {
            let seed = try crypto.guid()
            storageManager.setSDKSecretSeed(seed) { result in
                guard result.isSuccess(else: completion) else { return }
                
                completion(runCatching { try crypto.keyPairFrom(seed: seed) })
            }
        } catch {
            completion(.failure(error))
        }
    }
}

// MARK: Extensions

extension Beacon {
    
    static func reset() {
        shared = nil
    }
}
