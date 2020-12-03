//
//  MockCoin.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 01.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
@testable import BeaconSDK

class MockCoin: Coin {
    func getAddressFrom(publicKey: String) throws -> String {
        publicKey
    }
}
