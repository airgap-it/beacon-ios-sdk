//
//  MockSecureStorage.swift
//  BeaconSDK
//
//  Created by Julia Samol on 07.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

class MockSecureStorage: SecureStorage {
    var sdkSecretSeed: String?
    
    func getSDKSecretSeed(completion: @escaping (Result<String?, Error>) -> ()) {
        completion(.success(sdkSecretSeed))
    }
    
    func setSDKSecretSeed(_ seed: String, completion: @escaping (Result<(), Error>) -> ()) {
        sdkSecretSeed = seed
        completion(.success(()))
    }
}
