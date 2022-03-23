//
//  IdentifierCreatorTests.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 30.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import XCTest
import Common

@testable import BeaconCore

class IdentifierCreatorTests: XCTestCase {
    
    private var identifierCreator: IdentifierCreator!
    private var crypto: Crypto!

    override func setUpWithError() throws {
        crypto = Crypto(provider: SodiumCryptoProvider())
        identifierCreator = IdentifierCreator(crypto: crypto)
    }

    override func tearDownWithError() throws {
        identifierCreator = nil
        crypto = nil
    }

    func testAccountIdentifier() throws {
        let testCases = [
            AccountIdentifierTestCase(address: "address", network: .init(type: "custom"), expected: "2J9S9Zb9MquBkrY2LP31"),
            AccountIdentifierTestCase(address: "address", network: .init(type: "custom", name: "custom"), expected: "SpHGthQuUrDhajCFTkF"),
            AccountIdentifierTestCase(address: "address", network: .init(type: "custom", rpcURL: "customURL"), expected: "2XFC36qtPSn4vxpHZy67"),
            AccountIdentifierTestCase(address: "address", network: .init(type: "custom", name: "custom", rpcURL: "customURL"), expected: "M5xdC6RrGHqJAgqGtbT")
        ]
        
        try testCases.forEach {
            let address = $0.address
            let network = $0.network
            let expected = $0.expected
            
            let actual = try identifierCreator.accountID(forAddress: address, onNetworkWithIdentifier: network.identifier)
            
            XCTAssertEqual(expected, actual, "Expected \(expected) for address \(address) and network \(network), but got \(actual)")
        }
    }
    
    func testSenderHash() throws {
        let testCases = [
            ("ee590deb81701168f6cb235726a867a5089790a5a03337fd16aea86fcc0e94fd", "2NMqTc7BaZaJg"),
            ("713225e96a9f002ee07d19d929053cdfa0701d44f393a82cc59739ed69d36a98", "22XoqkS7yDN5y")
        ]
        
        try testCases.forEach { (id, expected) in
            
            let actual = try identifierCreator.senderID(from: try HexString(from: id))
            
            XCTAssertEqual(expected, actual, "Expected \(expected) for id \(id), but got \(actual)")
        }
    }
    
    private struct AccountIdentifierTestCase {
        let address: String
        let network: MockNetwork
        
        let expected: String
    }
    
    static var allTests = [
        ("testAccountIdentifier", testAccountIdentifier),
        ("testSenderHash", testSenderHash),
    ]
}
