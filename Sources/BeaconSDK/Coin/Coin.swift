//
//  Coin.swift
//  BeaconSDK
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

protocol Coin {
    func getAddressFrom(publicKey: String) throws -> String
}

enum CoinType {
    case tezos
}
