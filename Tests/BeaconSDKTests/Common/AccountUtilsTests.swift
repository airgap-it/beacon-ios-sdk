//
//  AccountUtilsTests.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 30.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import XCTest
@testable import BeaconSDK

class AccountUtilsTests: XCTestCase {
    
    private var accountUtils: AccountUtils!
    private var crypto: Crypto!

    override func setUpWithError() throws {
        crypto = Crypto(provider: SodiumCryptoProvider())
        accountUtils = AccountUtils(crypto: crypto)
    }

    override func tearDownWithError() throws {
        accountUtils = nil
        crypto = nil
    }

    func testAccountIdentifier() throws {
        let testCases = [
            AccountIdentifierTestCase(address: "address", network: .init(type: .custom), expected: "2J9S9Zb9MquBkrY2LP31"),
            AccountIdentifierTestCase(address: "address", network: .init(type: .custom, name: "custom"), expected: "SpHGthQuUrDhajCFTkF"),
            AccountIdentifierTestCase(address: "address", network: .init(type: .custom, rpcURL: "customURL"), expected: "2XFC36qtPSn4vxpHZy67"),
            AccountIdentifierTestCase(address: "address", network: .init(type: .custom, name: "custom", rpcURL: "customURL"), expected: "M5xdC6RrGHqJAgqGtbT")
        ]
        
        try testCases.forEach {
            let address = $0.address
            let network = $0.network
            let expected = $0.expected
            
            let actual = try accountUtils.getAccountIdentifier(forAddress: address, on: network)
            
            XCTAssertEqual(expected, actual, "Expected \(expected) for address \(address) and network \(network), but got \(actual)")
        }
    }
    
    private struct AccountIdentifierTestCase {
        let address: String
        let network: Beacon.Network
        
        let expected: String
    }
    
    static var allTests = [
        ("testAccountIdentifier", testAccountIdentifier)
    ]
}
