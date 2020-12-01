//
//  BeaconTests.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import XCTest
@testable import BeaconSDK

class BeaconTests: XCTestCase {
    
    override func tearDownWithError() throws {
        Beacon.reset()
    }

    func testInitializationOnFirstRun() throws {
        let expect = expectation(description: "BeaconApp initialization")
        
        let appName = "mockApp"
        let storage = MockStorage()
        
        Beacon.initialize(appName: appName, storage: storage) { result in
            switch result {
            case .success(_):
                XCTAssertNotNil(Beacon.shared, "Beacon instance has not been initialized")
                
                let sdkVersion = storage.sdkVersion
                XCTAssertEqual(Beacon.Configuration.sdkVersion, sdkVersion, "Storage has not been initialized with a valid SDK version")
                
                guard let seed = storage.sdkSecretSeed else {
                    XCTFail("Storage has not been initialized with a seed")
                    break
                }
                
                let seedMatches = seed.range(of: CryptoTestsUtils.seedRegex, options: .regularExpression) != nil
                XCTAssertTrue(seedMatches, "Storage has not been initialized with a valid seed")
                
                guard let crypto = Beacon.shared?.dependencyRegistry.crypto else {
                    break
                }
                
                let expectedKeyPair = try! crypto.keyPairFrom(seed: seed)
                XCTAssertEqual(expectedKeyPair, Beacon.shared?.keyPair, "BeaconApp has been initialzied with an invalid keyPair")
                XCTAssertEqual(HexString(from: expectedKeyPair.publicKey).asString(), Beacon.shared?.beaconID, "beaconID is invalid")
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testInitialization timeout: \(error)")
            }
        }
    }
    
    func testInitializationOnEveryOtherRun() {
        let expect = expectation(description: "BeaconApp initialization")
        
        let appName = "mockApp"
        let storage = MockStorage()
        
        let storageSeed = "seed"
        storage.sdkSecretSeed = storageSeed
        storage.sdkVersion = "oldVersion"
        
        Beacon.initialize(appName: appName, storage: storage) { result in
            switch result {
            case .success(_):
                XCTAssertNotNil(Beacon.shared, "Beacon instance has not been initialized")
                
                let sdkVersion = storage.sdkVersion
                XCTAssertEqual(Beacon.Configuration.sdkVersion, sdkVersion, "Storage has not been initialized with a valid SDK version")
                
                guard let seed = storage.sdkSecretSeed else {
                    XCTFail("Storage has not been initialized with a seed")
                    break
                }
                XCTAssertEqual(storageSeed, seed, "Storage has overwritten the old seed")
                
                guard let crypto = Beacon.shared?.dependencyRegistry.crypto else {
                    break
                }
                
                let expectedKeyPair = try! crypto.keyPairFrom(seed: seed)
                XCTAssertEqual(expectedKeyPair, Beacon.shared?.keyPair, "BeaconApp has been initialzied with an invalid keyPair")
                XCTAssertEqual(HexString(from: expectedKeyPair.publicKey).asString(), Beacon.shared?.beaconID, "beaconID is invalid")
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testInitialization timeout: \(error)")
            }
        }
    }

    static var allTests = [
        ("testInitializationOnFirstRun", testInitializationOnFirstRun),
        ("testInitializationOnEveryOtherRun", testInitializationOnEveryOtherRun),
    ]
}
