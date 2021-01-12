//
//  Threshold.swift
//  BeaconSDK
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    /// Threshold configuration.
    /// The threshold is not enforced by Beacon on the dApp side. It has to be enforced in the wallet.
    public struct Threshold: Equatable, Codable {
        
        /// The amount of mutez that can be spend within the timeframe.
        public let amount: String
        
        /// The timeframe within which the spending will be summed up.
        public let timeframe: String
    }
}
