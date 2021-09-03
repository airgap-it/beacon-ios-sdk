//
//  TryUtils.swift
//  BeaconSDK
//
//  Created by Julia Samol on 25.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

func runCatching<T>(throwing block: () throws -> T) -> Result<T, Error> {
    do {
        return .success(try block())
    } catch {
        return .failure(error)
    }
}

func runCatching<T, R>(completion: @escaping (Result<R, Swift.Error>) -> (), throwing block: () throws -> T) -> T? {
    do {
        return try block()
    } catch {
        completion(.failure(error))
        return nil
    }
}

func completeCatching<T>(completion: @escaping (Result<T, Swift.Error>) -> (), throwing block: () throws -> T) {
    completion(runCatching(throwing: block))
}

func completeCatching(completion: @escaping (Result<(), Swift.Error>) -> (), throwing block: () throws -> ()) {
    completion(runCatching(throwing: block))
}
