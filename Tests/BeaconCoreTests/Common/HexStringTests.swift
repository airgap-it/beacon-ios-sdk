//
//  HexStringTests.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 11.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import XCTest
@testable import BeaconCore

class HexStringTests: XCTestCase {
    
    private static let hexPrefix = "0x"
    
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
    
    func testHexStringIsCreatedFromValidString() throws {
        validHexStrings.forEach { string in
            XCTAssertEqual(withoutPrefix(string), try! HexString(from: string).asString(), "Created HexString doesn't match expected")
        }
    }
    
    func testHexStringNotCreatedFromInvalidString() throws {
        for string in invalidHexStrings {
            XCTAssertThrowsError(try HexString(from: string), "A `notHex` Error should have been thrown, but no error was thrown") { error in
                XCTAssertEqual(error as? HexString.Error, HexString.Error.invalidHex(string))
            }
        }
    }
    
    func testHexStringIsCreatedFromBytes() throws {
        let bytesWithExpected: [([UInt8], String)] = [
            ([0], "00"),
            ([148, 52, 220, 152], "9434dc98"),
            ([123, 30, 162, 203], "7b1ea2cb"),
            ([228, 4, 118, 215], "e40476d7"),
            ([196, 115, 32, 171, 221, 49], "c47320abdd31"),
            ([87, 134, 218, 201, 234, 244], "5786dac9eaf4"),
        ]
        
        bytesWithExpected.forEach { (bytes, expected) in
            XCTAssertEqual(expected, HexString(from: bytes).asString(), "Created HexString doesn't match expected")
        }
    }
    
    func testHexStringIsCreatedFromPositiveInt() throws {
        let intsWithExpected: [(Int, String)] = [
            (0, "00"),
            (10, "0a"),
            (154, "9a"),
            (5435, "153b"),
            (6855643, "689bdb")
        ]
        
        try intsWithExpected.forEach { (int, expected) in
            XCTAssertEqual(expected, try HexString(from: int).asString(), "Created HexString doesn't match expected")
        }
    }
    
    func testHexStringIsNotCreatedFromNegativeInt() throws {
        let negatives = [-1, -24, -156, -363, -6764]
        
        for int in negatives {
            XCTAssertThrowsError(try HexString(from: int), "A `negativeInt` Error should have been thrown, but no error was thrown") { error in
                XCTAssertEqual(error as? HexString.Error, HexString.Error.negativeInt(int))
            }
        }
    }
    
    func testHexStringValueIsReturnedWithPrefix() throws {
        let hex = validHexStrings.first!
        
        XCTAssertEqual(withPrefix(hex), try HexString(from: hex).asString(withPrefix: true))
    }
    
    func testHexStringValueIsReturnedWithoutPrefix() throws {
        let hex = validHexStrings.first!
        
        XCTAssertEqual(withoutPrefix(hex), try HexString(from: hex).asString())
    }
    
    func testHexStringCountIsReturnedIncludingPrefix() throws {
        let hex = validHexStrings.first!
        
        XCTAssertEqual(withPrefix(hex).count, try HexString(from: hex).count(withPrefix: true))
    }
    
    func testHexStringCountIsReturnedExcludingPrefix() throws {
        let hex = validHexStrings.first!
        
        XCTAssertEqual(withoutPrefix(hex).count, try HexString(from: hex).count())
    }
    
    func testHexStringIsConvertedToBytes() throws {
        let stringsWithExpected: [(String, [UInt8])] = [
            ("00", [0]),
            ("9434dc98", [148, 52, 220, 152]),
            ("7b1ea2cb", [123, 30, 162, 203]),
            ("e40476d7", [228, 4, 118, 215]),
            ("c47320abdd31", [196, 115, 32, 171, 221, 49]),
            ("5786dac9eaf4", [87, 134, 218, 201, 234, 244]),
        ]
        
        stringsWithExpected.forEach { (string, expected) in
            XCTAssertEqual(expected, try! HexString(from: string).asBytes(), "Bytes from HexString don't match expected")
        }
    }
    
    private func withPrefix(_ string: String) -> String {
        return string.hasPrefix(HexStringTests.hexPrefix) ? string : HexStringTests.hexPrefix + string
    }
    
    private func withoutPrefix(_ string: String) -> String {
        guard string.hasPrefix(HexStringTests.hexPrefix) else {
            return string
        }
        
        let index = string.index(string.startIndex, offsetBy: HexStringTests.hexPrefix.count)
        return String(string[index...])
    }
    
    static var allTests = [
        ("testHexStringIsCreatedFromValidString", testHexStringIsCreatedFromValidString),
        ("testHexStringNotCreatedFromInvalidString", testHexStringNotCreatedFromInvalidString),
        ("testHexStringIsCreatedFromBytes", testHexStringIsCreatedFromBytes),
        ("testHexStringIsCreatedFromPositiveInt", testHexStringIsCreatedFromPositiveInt),
        ("testHexStringIsNotCreatedFromNegativeInt", testHexStringIsNotCreatedFromNegativeInt),
        ("testHexStringValueIsReturnedWithPrefix", testHexStringValueIsReturnedWithPrefix),
        ("testHexStringValueIsReturnedWithoutPrefix", testHexStringValueIsReturnedWithoutPrefix),
        ("testHexStringCountIsReturnedIncludingPrefix", testHexStringCountIsReturnedIncludingPrefix),
        ("testHexStringCountIsReturnedExcludingPrefix", testHexStringCountIsReturnedExcludingPrefix),
        ("testHexStringIsConvertedToBytes", testHexStringIsConvertedToBytes),
    ]
}
