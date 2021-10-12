//
//  SigningType.swift
//
//
//  Created by Julia Samol on 02.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Tezos {
    
    /// Types of signatures supported in Beacon.
    public enum SigningType: String, Codable, Equatable {
        
        /// An arbitrary payload, which will be hashed before signing
        case raw
        
        /// Operation payload, prefixed with the "0x03" watermark
        case operation
        
        /// Micheline payload, prefixed with the "0x05" watermark
        case micheline
    }
}
