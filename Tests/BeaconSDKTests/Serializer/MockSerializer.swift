//
//  MockSerializer.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 01.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
@testable import BeaconSDK

class MockSerializer: Serializer {
    func serialize<T>(message: T) throws -> String where T : Decodable, T : Encodable {
        let encoder = JSONEncoder()
        return String(data: try encoder.encode(message), encoding: .utf8) ?? ""
    }
    
    func deserialize<T>(message: String, to type: T.Type) throws -> T where T : Decodable, T : Encodable {
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: Data(message.utf8))
    }
}
