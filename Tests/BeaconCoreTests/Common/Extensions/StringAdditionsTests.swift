//
//  StringAdditionsTests.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 30.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import XCTest
@testable import BeaconCore

class StringAdditionsTests: XCTestCase {
    
    private let validHexStrings = [
        "",
        "9434dc98",
        "0x7b1ea2cb",
        "e40476d7",
        "c47320abdd31",
        "0x5786dac9eaf4",
        "0x",
    ]
    
    private let invalidHexStrings = [
        "9434dc98az",
        "0xe40476d77t",
        "0x1",
    ]
    
    func testIsHex() throws {
        validHexStrings.forEach { string in
            XCTAssertTrue(string.isHex, "Valid hex string (\(string)) was recognized as invalid")
        }
        
        invalidHexStrings.forEach { string in
            XCTAssertFalse(string.isHex, "Invalid hex string (\(string)) was recognized as valid")
        }
    }

    func testPrefix() throws {
        let separator: Character = "."
        let stringsWithExpected = [
            ("1", "1"),
            ("1\(separator)0\(separator)1", "1"),
            ("10\(separator)1", "10"),
        ]
        
        for (string, expected) in stringsWithExpected {
            XCTAssertEqual(expected, string.prefix(before: separator))
        }
    }
    
    static var allTests = [
        ("testIsHex", testIsHex),
        ("testPrefix", testPrefix),
    ]

}
