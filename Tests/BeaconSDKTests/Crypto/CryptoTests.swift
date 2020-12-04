//
//  CryptoTests.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import XCTest
@testable import BeaconSDK

class CryptoTests: XCTestCase {
    private var crypto: Crypto!
    private var cryptoProvider: CryptoProvider!
    
    override func setUpWithError() throws {
        super.setUp()
        
        cryptoProvider = SodiumCryptoProvider()
        crypto = Crypto(provider: cryptoProvider)
    }
    
    override func tearDownWithError() throws {
        crypto = nil
        cryptoProvider = nil
    }
    
    func testRandomSeed() throws {
        let seed = try! crypto.guid()
        let matches = seed.range(of: CryptoTestsUtils.seedRegex, options: .regularExpression) != nil
        
        XCTAssertTrue(matches, "Seed doesn't match its pattern")
    }
    
    func testKeyPairFromSeed() throws {
        let seed = "seed"
        let keyPair = try! crypto.keyPairFrom(seed: seed)
        
        let expectedSecretKey: [UInt8] = [
            4, 216,  67, 107, 184,  67, 205,  12,  16, 226, 205,
          198, 194,  65,   3, 177, 195, 243, 136,  49,  31, 157,
          143,  12, 135,  76, 171, 194, 120, 151,  17, 124, 135,
          112,  93, 122, 125, 150,  72,  54,  30, 129, 184, 238,
           92, 194,  45, 156, 192, 248,  55, 107,  17, 248, 127,
          187,  82, 126,  88, 213, 222, 125, 245,  38
        ]
        
        let expectedPublicKey: [UInt8] = [
            135, 112,  93, 122, 125, 150,  72,  54,
             30, 129, 184, 238,  92, 194,  45, 156,
            192, 248,  55, 107,  17, 248, 127, 187,
             82, 126,  88, 213, 222, 125, 245,  38
        ]
        
        XCTAssertEqual(expectedSecretKey, keyPair.secretKey, "Secret key doesn't match")
        XCTAssertEqual(expectedPublicKey, keyPair.publicKey, "Public key doesn't match")
    }
    
    static var allTests = [
        ("testRandomSeed", testRandomSeed),
        ("testKeyPairFromSeed", testKeyPairFromSeed),
    ]
}
