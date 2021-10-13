//
//  Key.swift
//
//
//  Created by Julia Samol on 10.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public struct KeyPair: Equatable {
    public let secretKey: [UInt8]
    public let publicKey: [UInt8]
    
    init(secretKey: [UInt8], publicKey: [UInt8]) {
        self.secretKey = secretKey
        self.publicKey = publicKey
    }
}

public struct SessionKeyPair {
    public let rx: [UInt8]
    public let tx: [UInt8]
}
