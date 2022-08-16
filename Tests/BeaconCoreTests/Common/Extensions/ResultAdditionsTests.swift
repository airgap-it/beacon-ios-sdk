//
//  ResultAdditionsTests.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 30.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import XCTest
@testable import BeaconCore

class ResultAdditionsTests: XCTestCase {

    func testIsSuccess() throws {
        let success: Result<(), Swift.Error> = .success(())
        let failure: Result<(), Swift.Error> = .failure(Error.unknown)
        
        XCTAssertTrue(success.isSuccess, "Expected a success result to be recognized as success")
        XCTAssertFalse(failure.isSuccess, "Expected a failure result not to be recognized as success")
    }
    
    func testError() throws {
        let success: Result<(), Swift.Error> = .success(())
        
        let error = Error.unknown
        let failure: Result<(), Swift.Error> = .failure(error)
        
        XCTAssertNil(success.error, "Expected a success result not to return an error")
        XCTAssertEqual(error, failure.error as? Error, "Expected a failure result to return an error")
    }
    
    func testIsSuccessElseCompletion() throws {
        var successCompletionCalled = false
        var failureCompletionCalled = false
        
        let success: Result<(), Error> = .success(())
        let failure: Result<(), Error> = .failure(Error.unknown)
        
        let successResult = success.isSuccess(else: { (_: Result<(), Error>) in successCompletionCalled = true })
        let failureResult = failure.isSuccess(else: { (_: Result<(), Error>) in failureCompletionCalled = true })
        
        XCTAssertTrue(successResult, "Expected a success result to be recognized as success")
        XCTAssertFalse(successCompletionCalled, "Expected the success completion not to be called")
        
        XCTAssertFalse(failureResult, "Expected a failure result not to be recognized as success")
        XCTAssertTrue(failureCompletionCalled, "Expected the failure completion to be called")
   }
    
    func testGetValueOrCompletionIfFailure() throws {
        let value = "value"
        
        var successCompletionCalled = false
        var failureCompletionCalled = false
        
        let success: Result<String, Error> = .success(value)
        let failure: Result<String, Error> = .failure(Error.unknown)
        
        let successResult = success.get(ifFailure: { (_: Result<(), Error>) in successCompletionCalled = true })
        let failureResult = failure.get(ifFailure: { (_: Result<(), Error>) in failureCompletionCalled = true })
        
        XCTAssertEqual(value, successResult, "Expected a success result to return the specified value")
        XCTAssertFalse(successCompletionCalled, "Expected the success completion not to be called")
        
        XCTAssertNil(failureResult, "Expected a failure result not to return any value")
        XCTAssertTrue(failureCompletionCalled, "Expected the failure completion to be called")
    }
    
    func testIsSuccessElseCompletionWithBeaconError() throws {
        var successCompletionCalled = false
        var failureCompletionCalled = false
        
        let success: Result<(), Error> = .success(())
        let failure: Result<(), Error> = .failure(Error.unknown)
        
        let successResult = success.isSuccess(else: { (_: Result<(), Beacon.Error>) in successCompletionCalled = true })
        let failureResult = failure.isSuccess(else: { (_: Result<(), Beacon.Error>) in failureCompletionCalled = true })
        
        XCTAssertTrue(successResult, "Expected a success result to be recognized as success")
        XCTAssertFalse(successCompletionCalled, "Expected the success completion not to be called")
        
        XCTAssertFalse(failureResult, "Expected a failure result not to be recognized as success")
        XCTAssertTrue(failureCompletionCalled, "Expected the failure completion to be called")
   }
    
    func testGetValueOrCompletionWithBeaconErrorIfFailure() throws {
        let value = "value"
        
        var successCompletionCalled = false
        var failureCompletionCalled = false
        
        let success: Result<String, Error> = .success(value)
        let failure: Result<String, Error> = .failure(Error.unknown)
        
        let successResult = success.get(ifFailureWithBeaconError: { (_: Result<(), Beacon.Error>) in successCompletionCalled = true })
        let failureResult = failure.get(ifFailureWithBeaconError: { (_: Result<(), Beacon.Error>) in failureCompletionCalled = true })
        
        XCTAssertEqual(value, successResult, "Expected a success result to return the specified value")
        XCTAssertFalse(successCompletionCalled, "Expected the success completion not to be called")
        
        XCTAssertNil(failureResult, "Expected a failure result not to return any value")
        XCTAssertTrue(failureCompletionCalled, "Expected the failure completion to be called")
    }
    
    private enum Error: Swift.Error, Equatable {
        case unknown
    }
    
    static var allTests = [
        ("testIsSuccess", testIsSuccess),
        ("testError", testError),
        ("testIsSuccessElseCompletion", testIsSuccessElseCompletion),
        ("testGetValueOrCompletionFailure", testGetValueOrCompletionIfFailure),
        ("testIsSuccessElseCompletionWithBeaconError", testIsSuccessElseCompletionWithBeaconError),
        ("testGetValueOrCompletionWithBeaconErrorFailure", testGetValueOrCompletionWithBeaconErrorIfFailure),
    ]

}
