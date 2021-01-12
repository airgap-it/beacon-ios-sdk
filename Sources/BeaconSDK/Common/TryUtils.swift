//
//  TryUtils.swift
//  BeaconSDK
//
//  Created by Julia Samol on 25.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

func catchResult<T>(throwing block: () throws -> T) -> Result<T, Error> {
    do {
        return .success(try block())
    } catch {
        return .failure(error)
    }
}
