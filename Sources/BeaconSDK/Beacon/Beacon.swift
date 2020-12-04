//
//  Beacon.swift
//  BeaconSDK
//
//  Created by Julia Samol on 10.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public class Beacon {

    private(set) static var shared: Beacon? = nil
    
    let dependencyRegistry: DependencyRegistry
    let appName: String
    let keyPair: KeyPair
    
    var beaconID: String {
        HexString(from: keyPair.publicKey).asString()
    }
    
    private init(dependencyRegistry: DependencyRegistry, appName: String, keyPair: KeyPair) {
        self.dependencyRegistry = dependencyRegistry
        self.appName = appName
        self.keyPair = keyPair
    }
    
    // MARK: Initialization
    
    static func initialize(
        appName: String,
        storage: Storage,
        completion: @escaping (Result<(Beacon), Swift.Error>) -> ()
    ) {
        if let beacon = shared {
            completion(.success(beacon))
            return
        }
        
        let dependencyRegistry = DependencyRegistry(storage: storage)
        let crypto = dependencyRegistry.crypto
        
        setSDKVersion(savedIn: storage) { result in
            guard result.isSuccess(else: completion) else { return }
            
            self.loadOrGenerateKeyPair(using: crypto, savedIn: storage) { result in
                guard let keyPair = result.get(ifFailure: completion) else { return }
                let beacon = Beacon(dependencyRegistry: dependencyRegistry, appName: appName, keyPair: keyPair)
                shared = beacon
                
                completion(.success(beacon))
            }
        }
    }
    
    private static func setSDKVersion(savedIn storage: Storage, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.setSDKVersion(Beacon.Configuration.sdkVersion, completion: completion)
    }
    
    private static func loadOrGenerateKeyPair(
        using crypto: Crypto,
        savedIn storage: Storage,
        completion: @escaping (Result<KeyPair, Swift.Error>) -> ()
    ) {
        storage.getSDKSecretSeed { result in
            guard let storageSeed = result.get(ifFailure: completion) else { return }
            
            if let seed = storageSeed {
                completion(catchResult { try crypto.keyPairFrom(seed: seed) })
            } else {
                self.generateKeyPair(using: crypto, savedIn: storage, completion: completion)
            }
        }
    }
    
    private static func generateKeyPair(using crypto: Crypto, savedIn storage: Storage, completion: @escaping (Result<KeyPair, Swift.Error>) -> ()) {
        do {
            let seed = try crypto.guid()
            storage.setSDKSecretSeed(seed) { result in
                guard result.isSuccess(else: completion) else { return }
                
                completion(catchResult { try crypto.keyPairFrom(seed: seed) })
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
