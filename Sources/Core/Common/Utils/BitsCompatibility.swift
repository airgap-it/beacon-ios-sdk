//
//  BitsCompatibility.swift
//  
//
//  Created for Octez Connect iOS SDK migration
//
//  Compatibility layer for Bits types when building via CocoaPods
//  This provides the same types as the swift-bits SPM package

import Foundation

/// A single byte represented as a UInt8
public typealias Byte = UInt8

/// A byte array or collection of raw data
public typealias Bytes = Array<Byte>

/// A sliced collection of raw data
public typealias BytesSlice = ArraySlice<Byte>

// MARK: Byte Extensions

public extension Byte {
    static var one: Byte { return 0x31 }
    static var two: Byte { return 0x32 }
    static var three: Byte { return 0x33 }
    static var four: Byte { return 0x34 }
    static var five: Byte { return 0x35 }
    static var six: Byte { return 0x36 }
    static var seven: Byte { return 0x37 }
    static var eight: Byte { return 0x38 }
    static var nine: Byte { return 0x39 }
    static var A: Byte { return 0x41 }
    static var B: Byte { return 0x42 }
    static var C: Byte { return 0x43 }
    static var D: Byte { return 0x44 }
    static var E: Byte { return 0x45 }
    static var F: Byte { return 0x46 }
    static var G: Byte { return 0x47 }
    static var H: Byte { return 0x48 }
    static var J: Byte { return 0x4A }
    static var K: Byte { return 0x4B }
    static var L: Byte { return 0x4C }
    static var M: Byte { return 0x4D }
    static var N: Byte { return 0x4E }
    static var P: Byte { return 0x50 }
    static var Q: Byte { return 0x51 }
    static var R: Byte { return 0x52 }
    static var S: Byte { return 0x53 }
    static var T: Byte { return 0x54 }
    static var U: Byte { return 0x55 }
    static var V: Byte { return 0x56 }
    static var W: Byte { return 0x57 }
    static var X: Byte { return 0x58 }
    static var Y: Byte { return 0x59 }
    static var Z: Byte { return 0x5A }
    static var a: Byte { return 0x61 }
    static var b: Byte { return 0x62 }
    static var c: Byte { return 0x63 }
    static var d: Byte { return 0x64 }
    static var e: Byte { return 0x65 }
    static var f: Byte { return 0x66 }
    static var g: Byte { return 0x67 }
    static var h: Byte { return 0x68 }
    static var i: Byte { return 0x69 }
    static var j: Byte { return 0x6A }
    static var k: Byte { return 0x6B }
    static var m: Byte { return 0x6D }
    static var n: Byte { return 0x6E }
    static var o: Byte { return 0x6F }
    static var p: Byte { return 0x70 }
    static var q: Byte { return 0x71 }
    static var r: Byte { return 0x72 }
    static var s: Byte { return 0x73 }
    static var t: Byte { return 0x74 }
    static var u: Byte { return 0x75 }
    static var v: Byte { return 0x76 }
    static var w: Byte { return 0x77 }
    static var x: Byte { return 0x78 }
    static var y: Byte { return 0x79 }
    static var z: Byte { return 0x7A }
}

// MARK: String Extension

public extension String {
    /// Initialize a String from Bytes (UTF-8 encoded)
    init(_ bytes: Bytes) throws {
        guard let value = String(bytes: bytes, encoding: .utf8) else {
            throw BitsCompatibilityError.invalidStringEncoding
        }
        self = value
    }
    
    /// Convert String to Bytes (UTF-8 encoded)
    func makeBytes() -> Bytes {
        return Bytes(utf8)
    }
}

// MARK: Error Types

public enum BitsCompatibilityError: Error {
    case invalidStringEncoding
}
