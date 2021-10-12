//
//  BeaconTests.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import XCTest
import Common

@testable import BeaconCore

class BeaconTests: XCTestCase {
    
    override func tearDownWithError() throws {
        Beacon.reset()
    }

    func testInitializationOnFirstRun() throws {
        let testExpectation = expectation(description: "BeaconApp initialization")
        
        let appName = "mockApp"
        let storage = MockStorage()
        let secureStorage = MockSecureStorage()
        
        Beacon.initialize(appName: appName, appIcon: nil, appURL: nil, blockchainFactories: [], storage: storage, secureStorage: secureStorage) { result in
            switch result {
            case .success(_):
                XCTAssertNotNil(Beacon.shared, "Beacon instance has not been initialized")
                
                let sdkVersion = storage.sdkVersion
                XCTAssertEqual(Beacon.Configuration.sdkVersion, sdkVersion, "Storage has not been initialized with a valid SDK version")
                
                guard let seed = secureStorage.sdkSecretSeed else {
                    XCTFail("Storage has not been initialized with a seed")
                    break
                }
                
                let seedMatches = seed.range(of: CryptoTestsUtils.seedRegex, options: .regularExpression) != nil
                XCTAssertTrue(seedMatches, "Storage has not been initialized with a valid seed")
                
                guard let crypto = Beacon.shared?.dependencyRegistry.crypto else {
                    break
                }
                
                let expectedKeyPair = try! crypto.keyPairFrom(seed: seed)
                XCTAssertEqual(expectedKeyPair, Beacon.shared?.app.keyPair, "BeaconApp has been initialzied with an invalid keyPair")
                XCTAssertEqual(HexString(from: expectedKeyPair.publicKey).asString(), Beacon.shared?.beaconID, "beaconID is invalid")
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testInitializationOnFirstRun timeout: \(error)")
            }
        }
    }
    
    func testInitializationOnEveryOtherRun() {
        let testExpectation = expectation(description: "BeaconApp initialization")
        
        let appName = "mockApp"
        let storage = MockStorage()
        let secureStorage = MockSecureStorage()
        
        let storageSeed = "seed"
        secureStorage.sdkSecretSeed = storageSeed
        storage.sdkVersion = "oldVersion"
        
        Beacon.initialize(appName: appName, appIcon: nil, appURL: nil, blockchainFactories: [], storage: storage, secureStorage: secureStorage) { result in
            switch result {
            case .success(_):
                XCTAssertNotNil(Beacon.shared, "Beacon instance has not been initialized")
                
                let sdkVersion = storage.sdkVersion
                XCTAssertEqual(Beacon.Configuration.sdkVersion, sdkVersion, "Storage has not been initialized with a valid SDK version")
                
                guard let seed = secureStorage.sdkSecretSeed else {
                    XCTFail("Storage has not been initialized with a seed")
                    break
                }
                XCTAssertEqual(storageSeed, seed, "Storage has overwritten the old seed")
                
                guard let crypto = Beacon.shared?.dependencyRegistry.crypto else {
                    break
                }
                
                let expectedKeyPair = try! crypto.keyPairFrom(seed: seed)
                XCTAssertEqual(expectedKeyPair, Beacon.shared?.app.keyPair, "BeaconApp has been initialzied with an invalid keyPair")
                XCTAssertEqual(HexString(from: expectedKeyPair.publicKey).asString(), Beacon.shared?.beaconID, "beaconID is invalid")
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testInitializationOnEveryOtherRun timeout: \(error)")
            }
        }
    }

    static var allTests = [
        ("testInitializationOnFirstRun", testInitializationOnFirstRun),
        ("testInitializationOnEveryOtherRun", testInitializationOnEveryOtherRun),
    ]
}
