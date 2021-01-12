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
        
        static var sdkVersion: String {
            Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        }
        
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
        static let matrixMaxSyncRetries: Int = 3
        static let defaultRelayServers: [URL] = [
            URL(string: "https://matrix.papers.tech"),
        ].compactMap { $0 }
        
        static let p2pReplicationCount: Int = 1
    }
}
