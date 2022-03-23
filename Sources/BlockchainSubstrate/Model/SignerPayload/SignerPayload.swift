//
//  SignerPayload.swift
//  
//
//  Created by Julia Samol on 10.03.22.
//

import Foundation

extension Substrate {
    
    public enum SignerPayload: SignerPayloadProtocol {
        case json(JSON)
        case raw(Raw)
        
        // MARK: Attributes
        
        public var type: `Type` {
            switch self {
            case let .json(content):
                return content.type
            case let .raw(content):
                return content.type
            }
        }
        
        // MARK: Codable
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(`Type`.self, forKey: .type)
            switch type {
            case .json:
                self = .json(try JSON(from: decoder))
            case .raw:
                self = .raw(try Raw(from: decoder))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            switch self {
            case let .json(content):
                try content.encode(to: encoder)
            case let .raw(content):
                try content.encode(to: encoder)
            }
        }
        
        // MARK: Types
        
        public enum `Type`: String, Codable {
            case json
            case raw
        }
        
        enum CodingKeys: String, CodingKey {
            case type
        }
        
        enum Error: Swift.Error {
            case invalidType
        }
    }
}

// MARK: Protocol

public protocol SignerPayloadProtocol: Codable, Equatable {
    var type: Substrate.SignerPayload.`Type` { get }
}
