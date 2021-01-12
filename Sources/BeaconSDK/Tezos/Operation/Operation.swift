//
//  Operation.swift
//  TezosKit
//
//  Created by Mike Godenzi on 18.10.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
extension Tezos {
    
    /// Types of Tezos operations supported in Beacon.
    public enum Operation: Codable, Equatable {
        case endorsement(Endorsement)
        case seedNonceRevelation(SeedNonceRevelation)
        case doubleEndorsementEvidence(DoubleEndorsementEvidence)
        case doubleBakingEvidence(DoubleBakingEvidence)
        case activateAccount(ActivateAccount)
        case proposals(Proposals)
        case ballot(Ballot)
        case reveal(Reveal)
        case transaction(Transaction)
        case origination(Origination)
        case delegation(Delegation)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let kind = try container.decode(Kind.self, forKey: .kind)
            switch kind {
            case .endorsement:
                self = .endorsement(try Endorsement(from: decoder))
            case .seedNonceRevelation:
                self = .seedNonceRevelation(try SeedNonceRevelation(from: decoder))
            case .doubleEndorsementEvidence:
                self = .doubleEndorsementEvidence(try DoubleEndorsementEvidence(from: decoder))
            case .doubleBakingEvidence:
                self = .doubleBakingEvidence(try DoubleBakingEvidence(from: decoder))
            case .activateAccount:
                self = .activateAccount(try ActivateAccount(from: decoder))
            case .proposals:
                self = .proposals(try Proposals(from: decoder))
            case .ballot:
                self = .ballot(try Ballot(from: decoder))
            case .reveal:
                self = .reveal(try Reveal(from: decoder))
            case .transaction:
                self = .transaction(try Transaction(from: decoder))
            case .origination:
                self = .origination(try Origination(from: decoder))
            case .delegation:
                self = .delegation(try Delegation(from: decoder))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            switch self {
            case let .endorsement(content):
                try content.encode(to: encoder)
            case let .seedNonceRevelation(content):
                try content.encode(to: encoder)
            case let .doubleEndorsementEvidence(content):
                try content.encode(to: encoder)
            case let .doubleBakingEvidence(content):
                try content.encode(to: encoder)
            case let .activateAccount(content):
                try content.encode(to: encoder)
            case let .proposals(content):
                try content.encode(to: encoder)
            case let .ballot(content):
                try content.encode(to: encoder)
            case let .reveal(content):
                try content.encode(to: encoder)
            case let .transaction(content):
                try content.encode(to: encoder)
            case let .origination(content):
                try content.encode(to: encoder)
            case let .delegation(content):
                try content.encode(to: encoder)
            }
        }
        
        public enum CodingKeys: String, CodingKey {
            case kind
        }
        
        public enum Kind: String, Codable {
            case endorsement
            case seedNonceRevelation = "seed_nonce_revelation"
            case doubleEndorsementEvidence = "double_endorsement_evidence"
            case doubleBakingEvidence = "double_baking_evidence"
            case activateAccount = "activate_account"
            case proposals
            case ballot
            case reveal
            case transaction
            case origination
            case delegation
        }
    }
}
