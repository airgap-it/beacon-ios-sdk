//
//  DictionaryAdditionsTests.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 30.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import XCTest
@testable import BeaconSDK

class DictionaryAdditionsTests: XCTestCase {

    func testGetOrSet() throws {
        let n = 3
        
        let defaultValue: UInt = 1
        var dictionary = [String: UInt]()
        var values = [Int]()
        
        var setterCalled = 0
        for _ in 0..<n {
            let value = dictionary.getOrSet("key") {
                setterCalled += 1
                return defaultValue
            }
            
            values.append(Int(value))
        }
        
        XCTAssertTrue(values.allSatisfy({ $0 == defaultValue }), "Expected dictionary to return \(defaultValue)")
        XCTAssertEqual(n, values.count, "Expected dictionary to return value every time, but it returned \(values.count)/\(n)")
        XCTAssertEqual(1, setterCalled, "Expected dictionary to call the setter only once")
    }

    static var allTests = [
        ("", testGetOrSet)
    ]
}
