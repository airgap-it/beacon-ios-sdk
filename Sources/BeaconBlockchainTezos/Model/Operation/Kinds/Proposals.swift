//
//  Proposals.swift
//  
//
//  Created by Mike Godenzi on 30.10.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Tezos.Operation {
    
    public struct Proposals: Codable, Equatable {
        public let kind: Kind
        public let period: Int
        public let proposals: [String]
        
        public init(period: Int, proposals: [String]) {
            kind = .proposals
            self.period = period
            self.proposals = proposals
        }
    }
}
