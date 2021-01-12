//
//  Parameters.swift
//  TezosKit
//
//  Created by Mike Godenzi on 30.10.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Tezos.Operation {
    
    public struct Parameters: Codable, Equatable {
        public let entrypoint: Entrypoint
        public let value: Micheline.MichelsonV1Expression
        
        public init(entrypoint: Entrypoint, value: Micheline.MichelsonV1Expression) {
            self.entrypoint = entrypoint
            self.value = value
        }
        
        public enum Entrypoint: Equatable, Codable {
            case common(Common)
            case custom(String)
            
            public init(from decoder: Decoder) throws {
                if let common = try? Common(from: decoder) {
                    self = .common(common)
                    return
                }
                let container = try decoder.singleValueContainer()
                let custom = try container.decode(String.self)
                self = .custom(custom)
            }
            
            public func encode(to encoder: Encoder) throws {
                switch self {
                case let .common(value):
                    try value.encode(to: encoder)
                case let .custom(value):
                    var container = encoder.singleValueContainer()
                    try container.encode(value)
                }
            }
            
            public enum Common: String, Codable {
                case `default`
                case root
                case `do`
                case setDelegate = "set_delegate"
                case removeDelegate = "remove_delegate"
            }
        }
    }
}
