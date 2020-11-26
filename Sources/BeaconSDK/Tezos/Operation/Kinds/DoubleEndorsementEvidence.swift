//
//  DoubleEndorsementEvidence.swift
//  TezosKit
//
//  Created by Mike Godenzi on 30.10.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Tezos.Operation {
    
    public struct DoubleEndorsementEvidence: Codable, Equatable {
        public let kind: Kind
        public let op1: InlinedEndorsement
        public let op2: InlinedEndorsement
        
        public init(op1: InlinedEndorsement, op2: InlinedEndorsement) {
            kind = .doubleEndorsementEvidence
            self.op1 = op1
            self.op2 = op2
    
        }
    }
}
