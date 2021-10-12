//
//  LazyWeakReferenceTests.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 30.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import XCTest
@testable import BeaconCore

class LazyWeakReferenceTests: XCTestCase {

    func testKeepsUsedReference() throws {
        let reference = LazyWeakReference { Stub() }
        
        let first = reference.value
        let second = reference.value
        
        XCTAssertTrue(first === second, "Expected `LazyWeakReference` to return the same instance")
    }
    
    func testDiscardsAndRecreatesReferenceIfUnsued() {
        let n = 2
        
        var created = 0
        let reference = LazyWeakReference { () -> Stub in
            created += 1
            return Stub()
        }
        
        var value: Stub?
        for _ in 0..<n {
            value = reference.value
            XCTAssertNotNil(value)
            value = nil
        }
        
        XCTAssertEqual(n, created, "Expected `LazyWeakReference` to create a new instance \(n) times, but it actually did \(created) times")
    }

    private class Stub {}
    
    static var allTests = [
        ("testKeepsUsedReference", testKeepsUsedReference),
        ("testDiscardsAndRecreatesReferenceIfUnused", testDiscardsAndRecreatesReferenceIfUnsued),
    ]
}
