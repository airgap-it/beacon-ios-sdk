//
//  P2PPairingResponse.swift
//
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public extension Transport.P2P {
    
    struct PairingResponse: Codable {
        let id: String
        let type: String
        let name: String
        let version: String
        let publicKey: String
        let relayServer: String
        let icon: String?
        let appURL: String?
        
        public init(id: String, type: String, name: String, version: String, publicKey: String, relayServer: String, icon: String?, appURL: String?) {
            self.id = id
            self.type = type
            self.name = name
            self.version = version
            self.publicKey = publicKey
            self.relayServer = relayServer
            self.icon = icon
            self.appURL = appURL
        }
        
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
