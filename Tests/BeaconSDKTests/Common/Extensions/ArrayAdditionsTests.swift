//
//  ArrayAdditionsTests.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 30.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import XCTest
@testable import BeaconSDK

class ArrayAdditionsTests: XCTestCase {
    
    func testPartitioned() throws {
        let n = 10
        
        let numbers = Array(0..<n)
        let evenExpected = numbers.filter { $0 % 2 == 0 }
        let oddExpected = numbers.filter { $0 % 2 != 0 }
        
        let (even, odd) = numbers.partitioned(by: { $0 % 2 == 0 })
        
        XCTAssertEqual(evenExpected, even)
        XCTAssertEqual(oddExpected, odd)
    }
    
    func testUnzip() throws {
        let zipped = [(1, "1"), (2, "2"), (3, "3"), (4, "4")]
        let (ints, strings) = zipped.unzip()
        
        XCTAssertEqual([1, 2, 3, 4], ints)
        XCTAssertEqual(["1", "2", "3", "4"], strings)
    }
    
    
    func testForEachAsync() throws {
        let n = 3
        
        let testExpectation = expectation(description: "forEachAsync returns an array of combined result values on completion")
        testExpectation.expectedFulfillmentCount = n + 1
        
        let array = Array(0..<n)
        array.forEachAsync(
            body: { (index, completion) in
                DispatchQueue.init(
                    label: "it.airgap.beacon-sdk-tests.testForEachAsyncValueCompletes#\(index)",
                    qos: .default,
                    target: .global(qos: .default)
                ).async {
                    testExpectation.fulfill()
                    completion(index)
                }
            },
            completion: { (results: [Int?]) in
                XCTAssertEqual(array, results, "Expected forEachAsync to return results in the same order as the collection's elements")
                testExpectation.fulfill()
            }
        )
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testForEachAsyncResult timeout: \(error)")
            }
        }
    }

    func testDistinct() throws {
        let duplication = 2
        let n = 2
        
        let elements = (0..<n).map { "element#\($0)" }
        let array = (0..<duplication).reduce([]) { (acc, _) in acc + elements.shuffled() }
        let distinct = array.distinct()
        
        XCTAssertEqual(elements.count, distinct.count, "Expected distinct array to have \(elements.count) elements, got \(distinct.count)")
    }
    
    private enum Error: Swift.Error {
        case unknown(id: Int)
    }
    
    static var allTests = [
        ("testPartitioned", testPartitioned),
        ("testUnzip", testUnzip),
        ("testForEachAsync", testForEachAsync),
        ("testDistinct", testDistinct),
    ]

}
