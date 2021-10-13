//
//  UserDefaultsSecureStorage.swift
//
//
//  Created by Julia Samol on 07.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import Security
import LocalAuthentication

public struct UserDefaultsSecureStorage: SecureStorage {
    
    private let userDefaults: UserDefaults
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    public func getSDKSecretSeed(completion: @escaping (Result<String?, Swift.Error>) -> ()) {
        guard let keyAlias = userDefaults.string(forKey: .keyAlias) else {
            completion(.success(nil))
            return
        }
        
        guard let keyTag = tag(forAlias: keyAlias) else {
            completion(.failure(Error.stringConversionFailure))
            return
        }
        
        retrieve(key: .sdkSeed, usingTag: keyTag) { result in
            guard let sdkSeed = result.get(ifFailure: completion) else { return }
            completion(.success(sdkSeed))
        }
    }
    
    public func setSDKSecretSeed(_ seed: String, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        let keyAlias: String = {
            if let keyAlias = userDefaults.string(forKey: .keyAlias) {
                return keyAlias
            } else {
                let keyAlias = UUID().uuidString
                userDefaults.set(keyAlias, forKey: .keyAlias)
                return keyAlias
            }
        }()
        
        guard let keyTag = tag(forAlias: keyAlias) else {
            completion(.failure(Error.stringConversionFailure))
            return
        }
        
        store(key: .sdkSeed, value: seed, usingTag: keyTag, completion: completion)
    }
    
    private func tag(forAlias alias: String) -> Data? {
        "it.airgap.beacon-sdk.key-\(alias)".data(using: .utf8)
    }
    
    private func store(key: SecuredKey, value: String, usingTag tag: Data, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        fetchBiometricSecuredKey(forTag: tag) { result in
            guard let secretKey = result.get(ifFailure: completion) else { return }
            do {
                try self.store(key: key, value: value, using: secretKey)
                completion(.success(()))
            } catch {
                completion(.failure(Error(error)))
            }
        }
    }

    private func store(key: SecuredKey, value: String, using secretKey: Keychain.PrivateKey) throws {
        guard let messageData = value.data(using: .utf8) else {
            throw Error.dataConversionFailure
        }
        let encryptedData = try secretKey.encrypt(data: messageData)
        let item = Keychain.Password(data: encryptedData, account: key.rawValue, protection: .whenUnlockedThisDeviceOnly)
        try item.save()
    }

    private func retrieve(key: SecuredKey, usingTag tag: Data, completion: @escaping (Result<String, Swift.Error>) -> ()) {
        fetchBiometricSecuredKey(forTag: tag) { result in
            guard let secretKey = result.get(ifFailure: completion) else { return }
            do {
                let value = try self.retrieve(key: key, using: secretKey)
                completion(.success(value))
            } catch {
                completion(.failure(Error(error)))
            }
        }
    }
    
    private func retrieve(key: SecuredKey, using secretKey: Keychain.PrivateKey) throws -> String {
        let item = try Keychain.Password.load(account: key.rawValue)
        let decryptedData = try secretKey.decrypt(data: item.data)
        guard let result = String(data: decryptedData as Data, encoding: .utf8) else {
            throw Error.stringConversionFailure
        }
        return result
    }

    private func generateNewBiometricSecuredKey(tag: Data) throws -> Keychain.PrivateKey {
        return try Keychain.PrivateKey(tag: tag, accessControl: [.privateKeyUsage], protection: .whenUnlockedThisDeviceOnly)
    }

    private func fetchSecretKey(forTag tag: Data, completion: @escaping (Result<Keychain.PrivateKey, Swift.Error>) -> ()) {
        do {
            let key = try Keychain.PrivateKey.load(tag: tag)
            completion(.success(key))
        } catch {
            DispatchQueue.global(qos: .default).async {
                completion(runCatching { try self.generateNewBiometricSecuredKey(tag: tag) })
            }
        }
    }

    @inline(__always) private func fetchBiometricSecuredKey(forTag tag: Data, completion: @escaping (Result<Keychain.PrivateKey, Swift.Error>) -> ()) {
        self.fetchSecretKey(forTag: tag, completion: completion)
    }
    
    // MARK: Types
    
    enum Key: String {
        case keyAlias
    }
    
    enum SecuredKey: String {
        case sdkSeed
    }

    enum Error: Swift.Error {
        case unknown
        case other(Swift.Error)
        case dataConversionFailure
        case stringConversionFailure

        init(_ error: Swift.Error?) {
            if let error = error as? Error {
                self = error
            } else if let error = error {
                self = .other(error)
            } else {
                self = .unknown
            }
        }
    }
}

// MARK: Extensions

private extension UserDefaults {
    func set(_ value: String, forKey key: UserDefaultsSecureStorage.Key) {
        set(value, forKey: key.rawValue)
    }
    
    func string(forKey key: UserDefaultsSecureStorage.Key) -> String? {
        string(forKey: key.rawValue)
    }
}
