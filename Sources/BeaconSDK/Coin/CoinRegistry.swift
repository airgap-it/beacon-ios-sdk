//
//  CoinRegistry.swift
//  BeaconSDK
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

class CoinRegistry: CoinRegistryProtocol {
    private let crypto: Crypto
    
    private var coins: [CoinType: Coin] = [:]
    
    init(crypto: Crypto) {
        self.crypto = crypto
    }
    
    func get(_ type: CoinType) -> Coin {
        coins.get(type) {
            switch type {
            case .tezos:
                return Tezos(crypto: crypto)
            }
        }
    }
}

protocol CoinRegistryProtocol {
    func get(_ type: CoinType) -> Coin
}
