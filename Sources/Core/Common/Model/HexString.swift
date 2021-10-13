//
//  HexString.swift
//
//
//  Created by Julia Samol on 20.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public struct HexString: Hashable, Equatable, Codable {
    static let prefix: String = "0x"
    
    private let value: String
    
    private init(_ value: String) {
        self.value = value.removing(prefix: HexString.prefix)
    }
    
    // MARK: Initialization
    
    public init(from string: String) throws {
        guard string.isHex else {
            throw Error.invalidHex(string)
        }
        
        self.init(string)
    }
    
    public init(from bytes: [UInt8]) {
        self.init(bytes.map { b in String(format: "%02x", b) }.joined())
    }
    
    public init(from int: Int) throws {
        guard int >= 0 else {
            throw Error.negativeInt(int)
        }
        
        self.init(String(format: "%02x", int))
    }
    
    // MARK: Attributes
    
    public func count(withPrefix prefixed: Bool = false) -> Int {
        asString(withPrefix: prefixed).count
    }
    
    // MARK: Converters
    
    public func asString(withPrefix prefixed: Bool = false) -> String {
        prefixed ? HexString.prefix + value : value
    }
    
    public func asBytes() throws -> [UInt8] {
        var bytes = [UInt8]()
        bytes.reserveCapacity(value.count / 2)
        
        for (position, index) in value.indices.enumerated() {
            guard position % 2 == 0 else {
                continue
            }
            let byteRange = index...value.index(after: index)
            let byteSlice = value[byteRange]
            guard let byte = UInt8(byteSlice, radix: 16) else {
                throw Error.invalidHex(String(byteSlice))
            }
            bytes.append(byte)
        }
        
        return bytes
    }
    
    // MARK: Types
    
    enum Error: Swift.Error, Equatable {
        case invalidHex(String)
        case negativeInt(Int)
    }
}
