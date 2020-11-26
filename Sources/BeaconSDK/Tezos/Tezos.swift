//
//  Tezos.swift
//  BeaconSDK
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public class Tezos: Coin {
    private let crypto: Crypto
    
    init(crypto: Crypto) {
        self.crypto = crypto
    }
    
    func getAddressFrom(publicKey: String) throws -> String {
        "" // TODO: implementation
    }
}
