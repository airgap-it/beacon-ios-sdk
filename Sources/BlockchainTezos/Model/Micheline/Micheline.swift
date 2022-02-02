//
//  Micheline.swift
//
//
//  Created by Mike Godenzi on 04.10.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public enum Micheline {
    
    public typealias Sequence = [MichelsonV1Expression]
    
    ///
    /// Base for JSON Micheline expressions.
    ///
    /// For more details see:
    /// - [Micheline White Doc](https://tezos.gitlab.io/whitedoc/micheline.html)
    /// - [Michelson White Doc](https://tezos.gitlab.io/whitedoc/michelson.html)
    ///
    public indirect enum MichelsonV1Expression: Codable, Equatable, Hashable {
        case prim(Prim)
        case literal(Literal)
        case sequence(Sequence)
        
        public init(from decoder: Decoder) throws {
            if let container = try? decoder.container(keyedBy: CodingKeys.self) {
                if container.contains(.prim) {
                    self = .prim(try Prim(from: decoder))
                } else {
                    self = .literal(try Literal(from: decoder))
                }
            } else {
                var container = try decoder.unkeyedContainer()
                self = .sequence(try Sequence(from: &container))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            switch self {
            case let .prim(prim):
                try prim.encode(to: encoder)
            case let .literal(literal):
                try literal.encode(to: encoder)
            case let .sequence(array):
                var container = encoder.unkeyedContainer()
                for mv1e in array {
                    try container.encode(mv1e)
                }
            }
        }
        
        public enum CodingKeys: String, CodingKey {
            case prim
        }
    }
}
