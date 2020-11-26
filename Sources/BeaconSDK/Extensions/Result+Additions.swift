//
//  Result+Additions.swift
//  BeaconSDK
//
//  Created by Julia Samol on 23.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Result {
    
    func isSuccess<T>(otherwise completion: @escaping (Result<T, Failure>) -> ()) -> Bool {
        switch self {
        case .success(_):
            return true
        case let .failure(error):
            completion(.failure(error))
            return false
        }
    }
    
    func get<T>(ifFailure completion: @escaping (Result<T, Failure>) -> ()) -> Success? {
        switch self {
        case let .success(value):
            return value
        case let .failure(error):
            completion(.failure(error))
            return nil
        }
    }
}
