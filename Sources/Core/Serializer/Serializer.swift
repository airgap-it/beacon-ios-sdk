//
//  Serializer.swift
//
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public protocol Serializer: AnyObject {
    func serialize<T: Encodable>(message: T) throws -> String
    func deserialize<T: Decodable>(message: String, to type: T.Type) throws -> T
}
