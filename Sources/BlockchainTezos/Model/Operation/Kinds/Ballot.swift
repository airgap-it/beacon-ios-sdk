//
//  Ballot.swift
//
//
//  Created by Mike Godenzi on 30.10.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Tezos.Operation {
    
    public struct Ballot: Codable, Equatable {
        public let kind: Kind
        public let source: String
        public let period: Int
        public let proposal: String
        public let ballot: Statement
        
        public init(source: String, period: Int, proposal: String, ballot: Statement) {
            kind = .ballot
            self.source = source
            self.period = period
            self.proposal = proposal
            self.ballot = ballot
        }
        
        public enum Statement: String, Codable {
            case nay
            case yay
            case pass
        }
    }
}
