//
//  SeedNonceRevelation.swift
//  
//
//  Created by Mike Godenzi on 30.10.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Tezos.Operation {
    
    public struct SeedNonceRevelation: Codable, Equatable {
        public let kind: Kind
        public let level: Int
        public let nonce: String
        
        public init(level: Int, nonce: String) {
            kind = .seedNonceRevelation
            self.level = level
            self.nonce = nonce
        }
    }
}
