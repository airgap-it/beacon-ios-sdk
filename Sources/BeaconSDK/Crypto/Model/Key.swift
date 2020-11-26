//
//  Key.swift
//  BeaconSDK
//
//  Created by Julia Samol on 10.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

struct KeyPair: Equatable {
    let secretKey: [UInt8]
    let publicKey: [UInt8]
    
    init(secretKey: [UInt8], publicKey: [UInt8]) {
        self.secretKey = secretKey
        self.publicKey = publicKey
    }
}

struct SessionKeyPair {
    let rx: [UInt8]
    let tx: [UInt8]
}
