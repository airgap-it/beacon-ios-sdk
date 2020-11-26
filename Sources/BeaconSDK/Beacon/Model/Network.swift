//
//  Network.swift
//  BeaconSDK
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    public struct Network: Codable, Equatable {
        public let type: `Type`
        public let name: String?
        public let rpcURL: String?
        
        init(type: `Type`, name: String? = nil, rpcURL: String? = nil) {
            self.type = type
            self.name = name
            self.rpcURL = rpcURL
        }
        
        enum CodingKeys: String, CodingKey {
            case type
            case name
            case rpcURL = "rpcUrl"
        }
        
        public enum `Type`: String, Codable {
            case mainnet
            case carthagenet
            case delphinet
            case custom
        }
    }
}
