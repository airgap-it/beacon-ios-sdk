//
//  HandshakeInfo.swift
//  BeaconSDK
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Transport.P2P {
    
    struct HandshakeInfo: Codable {
        let name: String
        let version: String
        let publicKey: String
        let relayServer: String
    }
}
