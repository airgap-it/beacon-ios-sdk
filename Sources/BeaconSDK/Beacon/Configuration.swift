//
//  Configuration.swift
//  BeaconSDK
//
//  Created by Julia Samol on 11.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    enum Configuration {
        
        // MARK: SDK
        
        static let sdkVersion: String = "beacon-iOS:1.0.4"
        
        static let cryptoProvider: CryptoProvider = .sodium
        static let serializer: Serializer = .base58check
        
        enum CryptoProvider {
            case sodium
        }
        
        enum Serializer {
            case base58check
        }
        
        // MARK: P2P
        
        static let matrixAPI: String = "/_matrix/client/r0"
        
        static let matrixClientAPIBase: String = "/_matrix/client"
        static let matrixClientAPIVersion: String = "r0"
        static let matrixClientRoomVersion: String = "5"
        
        static let matrixMaxSyncRetries: Int = 3
        
        static let p2pJoinDelaysMs: Int = 200
        static let p2pMaxJoinRetries: Int = 10
        
        static let defaultRelayServers: [String] = [
            "beacon-node-1.sky.papers.tech",
            "beacon-node-0.papers.tech:8448",
        ].compactMap { $0 }
    }
}
