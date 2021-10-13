//
//  Serializer.swift
//
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public protocol Serializer: AnyObject {
    func serialize<T: Codable>(message: T) throws -> String
    func deserialize<T: Codable>(message: String, to type: T.Type) throws -> T
}
