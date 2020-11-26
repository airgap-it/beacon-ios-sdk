//
//  Threshold.swift
//  BeaconSDK
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    public struct Threshold: Equatable, Codable {
        public let amount: String
        public let timeframe: String
    }
}
