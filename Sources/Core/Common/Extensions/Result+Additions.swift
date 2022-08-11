//
//  Result+Additions.swift
//
//
//  Created by Julia Samol on 23.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public extension Result {
    
    var isSuccess: Bool {
        switch self {
        case .success(_):
            return true
        case .failure(_):
            return false
        }
    }
    
    var error: Failure? {
        switch self {
        case .success(_):
            return nil
        case let .failure(error):
            return error
        }
    }
    
    func isSuccess<T>(else completion: @escaping (Result<T, Failure>) -> ()) -> Bool {
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
    
    func isSuccess<T>(else completion: @escaping (Result<T, Beacon.Error>) -> ()) -> Bool {
        switch self {
        case .success(_):
            return true
        case let .failure(error):
            completion(.failure(Beacon.Error(error)))
            return false
        }
    }
    
    func get<T>(ifFailureWithBeaconError completion: @escaping (Result<T, Beacon.Error>) -> ()) -> Success? {
        switch self {
        case let .success(value):
            return value
        case let .failure(error):
            completion(.failure(Beacon.Error(error)))
            return nil
        }
    }
    
    func withBeaconError() -> Result<Success, Beacon.Error> {
        mapError { Beacon.Error($0) }
    }
    
    func map<NewSuccess>(_ transform: (Success) throws -> NewSuccess) -> Result<NewSuccess, Swift.Error> {
        do {
            switch self {
            case let .success(value):
                return .success(try transform(value))
            case let .failure(error):
                throw error
            }
        } catch {
            return .failure(error)
        }
    }
}
