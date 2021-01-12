//
//  Endorsement.swift
//  TezosKit
//
//  Created by Mike Godenzi on 30.10.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Tezos.Operation {
    
    public struct Endorsement: Codable, Equatable {
        public let kind: Kind
        public let level: Int
        
        public init(level: Int) {
            kind = .endorsement
            self.level = level
        }
    }
}
