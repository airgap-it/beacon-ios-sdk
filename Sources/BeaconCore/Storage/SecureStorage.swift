//
//  SecureStorage.swift
//
//
//  Created by Julia Samol on 07.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public protocol SecureStorage {
    func getSDKSecretSeed(completion: @escaping (Result<String?, Error>) -> ())
    func setSDKSecretSeed(_ seed: String, completion: @escaping (Result<(), Error>) -> ())
}
