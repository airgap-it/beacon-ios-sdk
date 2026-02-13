//
//  P2PMatrixBeaconConfiguration.swift
//  
//
//  Created by Julia Samol on 27.09.21.
//

import Foundation
import OctezConnectCore

extension Beacon {
    
    public enum P2PMatrixConfiguration {
        public static let matrixAPI: String = "/_matrix/client/r0"
        
        public static let matrixClientAPIBase: String = "/_matrix/client"
        public static let matrixClientAPIVersion: String = "r0"
        public static let matrixClientRoomVersion: String = "5"
        
        public static let matrixMaxSyncRetries: Int = 3
        
        public static let p2pJoinDelaysMs: Int = 200
        public static let p2pMaxJoinRetries: Int = 10
        
        public static let defaultRelayServers: [String] = [
            "beacon-node-1.octez.io",
            "beacon-node-2.octez.io",
            "beacon-node-3.octez.io",
            "beacon-node-4.octez.io",
            "beacon-node-5.octez.io",
            "beacon-node-6.octez.io",
            "beacon-node-7.octez.io",
            "beacon-node-8.octez.io"
        ].compactMap { $0 }
    }
}
