//
//  Configuration.swift
//
//
//  Created by Julia Samol on 11.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public extension Beacon {
    
    enum Configuration {
        
        // MARK: SDK
        
        public static let sdkVersion: String = "3.2.1"
        
        public static let beaconVersion: String = "3"
        
        static let cryptoProvider: CryptoProvider = .sodium
        static let serializer: Serializer = .base58check
        
        enum CryptoProvider {
            case sodium
        }
        
        enum Serializer {
            case base58check
        }
    }
}
