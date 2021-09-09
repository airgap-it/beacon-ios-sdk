//
//  TryUtilsTests.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 30.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import XCTest
@testable import BeaconSDK

class TryUtilsTests: XCTestCase {

    func testCatchResult() throws {
        let value = "value"
        let error = Error.unknown
        
        let expectedSuccess = runCatching(throwing: { try returnOrFail(value, failWith: error) })
        let expectedFailure = runCatching(throwing: { try returnOrFail(value, failWith: error, fail: true) })
        
        switch expectedSuccess {
        case let .success(success):
            XCTAssertEqual(value, success)
        case .failure(_):
            XCTFail("Expected result to be a success")
        }
        
        switch expectedFailure {
        case .success(_):
            XCTFail("Expected result to be a failure")
        case let .failure(failure):
            XCTAssertEqual(error, failure as? Error)
        }
    }
    
    private func returnOrFail<T>(_ value: T, failWith error: Error, fail: Bool = false) throws -> T {
        if fail {
            throw error
        } else {
            return value
        }
    }
    
    private enum Error: Swift.Error, Equatable {
        case unknown
    }

    static var allTests = [
        ("testCatchResult", testCatchResult)
    ]
}
