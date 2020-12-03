//
//  TimeUtils.swift
//  BeaconSDK
//
//  Created by Julia Samol on 01.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

class TimeUtils: TimeUtilsProtocol {
    var currentTimeMillis: Int64 {
        Int64(Date().timeIntervalSince1970 * 1000)
    }
}

// MARK: Protcol

protocol TimeUtilsProtocol {
    var currentTimeMillis: Int64 { get }
}
