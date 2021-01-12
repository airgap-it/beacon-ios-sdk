//
//  DoubleBakingEvidence.swift
//  TezosKit
//
//  Created by Mike Godenzi on 30.10.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Tezos.Operation {
    
    public struct DoubleBakingEvidence: Codable, Equatable {
        public let kind: Kind
        public let bh1: BlockHeader
        public let bh2: BlockHeader
        
        public init(bh1: BlockHeader, bh2: BlockHeader) {
            kind = .doubleBakingEvidence
            self.bh1 = bh1
            self.bh2 = bh2
        }
    }
}
