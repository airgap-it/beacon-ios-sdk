//
//  WalletTests.swift
//  
//
//  Created by Julia Samol on 10.03.22.
//

import XCTest

@testable import BeaconCore
@testable import BeaconBlockchainTezos

class WalletTests: XCTestCase {
    
    var crypto: Crypto!
    var wallet: Tezos.Wallet!

    override func setUpWithError() throws {
        crypto = .init(provider: SodiumCryptoProvider())
        wallet = .init(crypto: crypto)
    }

    func testCreatesTezosAddressFromPlainPublicKey() throws {
        let publicKey = "452ef5736b7973c94427561900a17822a4948c1d8ed3aafd5007fa9656fd8f39"
        let address = try wallet.address(fromPublicKey: publicKey)
        
        XCTAssertEqual("tz1MMDnKwxp6Qp54zFxxZKFnrRX6h46XbTwr", address)
    }

    func testCreatesTezosAddressFromEncryptedPublicKey() throws {
        let publicKeysWithExpected = [
            ("edpkuAh8moaRkqGnVJUuwJywGcTEcuDx72o4K6j6zvYszmxNBC4V3D", "tz1MMDnKwxp6Qp54zFxxZKFnrRX6h46XbTwr"),
            ("sppk7ZpH5qAjTDZn1o1TW7z2QbQZUcMHRn2wtV4rRfz15eLQrvPkt6k", "tz2R3oTJR3cLfSyJVQiv8NGN4wXTQj58UYjp"),
            ("p2pk67fo5oy6byruqDtzVixbM7L3cVBDRMcFhA33XD5w2HF4fRXDJhw", "tz3duiskLgZdaEvkgEwWYF4mUnVXde7JTtef")
        ]
        
        for (publicKey, expected) in publicKeysWithExpected {
            let actual = try wallet.address(fromPublicKey: publicKey)
            
            XCTAssertEqual(expected, actual)
        }
    }

    static var allTests = [
        ("testCreatesTezosAddressFromPlainPublicKey", testCreatesTezosAddressFromPlainPublicKey),
        ("testCreatesTezosAddressFromEncryptedPublicKey", testCreatesTezosAddressFromEncryptedPublicKey)
    ]
}
