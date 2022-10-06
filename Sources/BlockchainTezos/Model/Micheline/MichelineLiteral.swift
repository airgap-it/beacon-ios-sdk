//
//  MichelineLiteral.swift
//  
//
//  Created by Mike Godenzi on 22.10.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore

extension Micheline {
    
    public enum Literal: Codable, Hashable, Equatable {
        case string(String)
        case int(String)
        case bytes([UInt8])
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let value = try container.decodeIfPresent(String.self, forKey: .string) {
                self = .string(value)
                return
            }
            if let value = try container.decodeIfPresent(String.self, forKey: .int) {
                self = .int(value)
                return
            }
            if let value = try container.decodeIfPresent(String.self, forKey: .bytes) {
                self = .bytes(try HexString(from: value).asBytes())
                return
            }
            throw SerializationError.invalidType
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case let .string(value):
                try container.encode(value, forKey: .string)
            case let .int(value):
                try container.encode(value, forKey: .int)
            case let .bytes(value):
                try container.encode(HexString(from: value).asString(withPrefix: false), forKey: .bytes)
            }
        }
        
        public enum CodingKeys: String, CodingKey {
            case string
            case int
            case bytes
        }
        
        public enum SerializationError: Swift.Error {
            case invalidType
        }
    }
}
