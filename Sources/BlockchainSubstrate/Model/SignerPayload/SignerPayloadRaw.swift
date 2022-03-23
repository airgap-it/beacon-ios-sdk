//
//  SignerPayloadRaw.swift
//  
//
//  Created by Julia Samol on 10.03.22.
//

import Foundation

extension Substrate.SignerPayload {
    
    public struct Raw: SignerPayloadProtocol {
        public let type: `Type` = .raw
        public let isMutable: Bool
        public let dataType: DataType
        public let data: String
        
        // MARK: Codable
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Self.CodingKeys.self)
            let type = try container.decode(`Type`.self, forKey: .type)
            guard type == .raw else {
                throw Error.invalidType
            }
            
            self.isMutable = try container.decode(Bool.self, forKey: .isMutable)
            self.dataType = try container.decode(DataType.self, forKey: .dataType)
            self.data = try container.decode(String.self, forKey: .data)
        }
        
        // MARK: Types
        
        public enum DataType: String, Codable {
            case bytes
            case payload
        }
    }
}
