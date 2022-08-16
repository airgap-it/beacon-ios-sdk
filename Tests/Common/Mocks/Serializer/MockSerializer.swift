//
//  MockSerializer.swift
//  Mocks
//
//  Created by Julia Samol on 01.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
@testable import BeaconCore

public class MockSerializer: Serializer {
    public init() {}
    
    public func serialize<T: Encodable>(message: T) throws -> String {
        let encoder = JSONEncoder()
        return String(data: try encoder.encode(message), encoding: .utf8) ?? ""
    }
    
    public func deserialize<T: Decodable>(message: String, to type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: Data(message.utf8))
    }
}
