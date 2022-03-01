//
//  P2PPairingResponse.swift
//
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public extension Transport.P2P {
    
    struct PairingResponse: Identifiable, Codable {
        public let id: String
        public let type: String
        public let name: String
        public let version: String
        public let publicKey: String
        public let relayServer: String
        public let icon: String?
        public let appURL: String?
        
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
