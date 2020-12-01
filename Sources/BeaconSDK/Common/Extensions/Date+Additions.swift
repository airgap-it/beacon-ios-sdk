//
//  Date+Additions.swift
//  BeaconSDK
//
//  Created by Julia Samol on 17.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Date {
    
    var currentTimeMillis: Int64 {
        Int64(timeIntervalSince1970 * 1000)
    }
}
