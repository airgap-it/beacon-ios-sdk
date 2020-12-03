//
//  SingleCallTests.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 30.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import XCTest
@testable import BeaconSDK

class SingleCallTests: XCTestCase {

    func testTargetActionRunsOnce() throws {
        let n = 3
        let testExpectation = expectation(description: "CachedCompletion finishes")
        
        var called = 0
        func targetAction(completion: @escaping (Result<(), Error>) -> ()) {
            called += 1
        }
        
        let singleCall: SingleCall<()> = .init()
        runAsync(times: n, body: { singleCall.run(body: targetAction, onResult: { _ in }, callback: $0) }) {
            XCTAssertEqual(1, called)
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testTargetAccountRunsOnce timeout: \(error)")
            }
        }
    }
    
    func testAllCompletionsCalled() throws {
        let n = 3
        
        let testExpectation = expectation(description: "CachedCompletion finishes")
        testExpectation.expectedFulfillmentCount = n
        
        var targetCompletion: ((Result<(), Error>) -> ())? = nil
        func targetAction(completion: @escaping (Result<(), Error>) -> ()) {
            targetCompletion = completion
        }
        
        let singleCall: SingleCall<()> = .init()
        runAsync(times: n, body: { singleCall.run(body: targetAction, onResult: { _ in testExpectation.fulfill() }, callback: $0) }) {
            targetCompletion?(.success(()))
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testAllCompletionsCalled timeout: \(error)")
            }
        }
    }
    
    static var allTests = [
        ("testTargetActionRunsOnce", testTargetActionRunsOnce),
        ("testAllCompletionsCalled", testAllCompletionsCalled),
    ]

}
