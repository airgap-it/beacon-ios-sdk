//
//  Base58CheckSerializer.swift
//
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import Base58Swift

class Base58CheckSerializer: Serializer {
    func serialize<T: Encodable>(message: T) throws -> String {
        let encoder = JSONEncoder()
        let jsonRaw = try encoder.encode(message)
        
        return Base58.base58CheckEncode(Array(jsonRaw))
    }
    
    func deserialize<T: Decodable>(message: String, to type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        guard let decoded = Base58.base58CheckDecode(message) else {
            throw Error.base58check
        }
        
        return try decoder.decode(type, from: Data(decoded))
    }
    
    // MARK: Types
    
    enum Error: Swift.Error {
        case base58check
    }
}
