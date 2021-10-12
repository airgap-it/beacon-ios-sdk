//
//  DistinguishableListenerTests.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 30.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import XCTest
@testable import BeaconCore

class DistinguishableListenerTests: XCTestCase {

    func testDistinguishable() throws {
        let first = DistinguishableListener {}
        let second = DistinguishableListener {}
        
        XCTAssertNotEqual(first, second, "Expected two `DistinguishableListener` instances not to be equal")
        XCTAssertNotEqual(first.hashValue, second.hashValue, "Expected two `DistinguishableListener` instances to have different hash values")
    }
    
    func testListenersAreEqualIfHaveSameID() throws {
        let id = "id"
        
        let first = DistinguishableListener(id: id) {}
        let second = DistinguishableListener(id: id) {}
        
        XCTAssertEqual(first, second, "Expected two `DistinguishableListener` instances with the same ID to be equal")
        XCTAssertEqual(first.hashValue, second.hashValue, "Expected two `DistinguishableListener` instances with the same ID to have the same hash values")
    }
    
    func testNotify() throws {
        let testExpectation = expectation(description: "DistinguishableListener notified")
        let value = "testValue"
        
        let listener: DistinguishableListener<String> = .init {
            XCTAssertEqual(value, $0, "Expected listener to be notified with \(value), but got \($0)")
            testExpectation.fulfill()
        }
        listener.notify(with: value)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testNotify timeout: \(error)")
            }
        }
    }

    static var allTests = [
        ("testDistinguishable", testDistinguishable),
        ("testListenersAreEqualIfHaveSameID", testListenersAreEqualIfHaveSameID),
        ("testNotify", testNotify),
    ]

}
