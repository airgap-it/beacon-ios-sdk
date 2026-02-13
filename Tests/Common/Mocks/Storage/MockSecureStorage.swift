//
//  MockSecureStorage.swift
//  Mocks
//
//  Created by Julia Samol on 07.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
@testable import OctezConnectCore

public class MockSecureStorage: SecureStorage {
    public var sdkSecretSeed: String?
    
    public init() {}
    
    public func getSDKSecretSeed(completion: @escaping (Result<String?, Error>) -> ()) {
        completion(.success(sdkSecretSeed))
    }
    
    public func setSDKSecretSeed(_ seed: String, completion: @escaping (Result<(), Error>) -> ()) {
        sdkSecretSeed = seed
        completion(.success(()))
    }
}
