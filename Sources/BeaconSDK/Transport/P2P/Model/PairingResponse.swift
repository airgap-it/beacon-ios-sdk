//
//  HandshakeInfo.swift
//  BeaconSDK
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Transport.P2P {
    
    struct PairingResponse: Codable {
        let id: String
        let type: String
        let name: String
        let version: String
        let publicKey: String
        let relayServer: String
        let icon: String?
        let appURL: String?
        
        // MARK: Codable
        
        enum CodingKeys: String, CodingKey {
            case id
            case type
            case name
            case version
            case publicKey
            case relayServer
            case icon
            case appURL = "appUrl"
        }
    }
}
